# UI Recipes → Flutter Implementation Contract (repo-tailored)

This contract is written for your current Flutter project structure:

```
lib/
  app.dart
  main.dart
  theme.dart
  controllers/session_controller.dart
  services/...
  ui/
    launch_screen.dart
    main_screen.dart
    session_screen.dart
    end_screen.dart
    settings_screen.dart
    history_screen.dart
    widgets/
```

It defines a deterministic mapping from **UI recipes** (tokens.yaml + components.yaml + screens/*.yaml)
to Flutter code, in a way that fits the repo and is friendly to AI coding agents.

---

## 1) Canonical UI recipe location

Treat the recipes as the **single source of truth**.

Recommended layout:

- `assets/ui_recipes/tokens.yaml`
- `assets/ui_recipes/components.yaml`
- `assets/ui_recipes/screens/*.yaml`

Commit this contract and the prompt template:

- `docs/ui_recipes/AGENT_CONTRACT_UI_RECIPES.md`
- `docs/ui_recipes/AGENT_PROMPT_TEMPLATE.md`

> Add `assets/ui_recipes/**` to `pubspec.yaml` under `flutter/assets:`.

---

## 2) Renderer module location (required)

Add a small renderer under:

- `lib/ui/widgets/recipe_renderer/`

Suggested files (you can merge/split as you like, but keep the responsibilities):

- `recipe_types.dart`  
  Model types: `RecipeScreen`, `RecipeElement`, etc.

- `recipe_loader.dart`  
  Loads YAML from assets (`rootBundle.loadString`) and parses.

- `recipe_expander.dart`  
  Expands `uses[]` from `components.yaml`, applies `${prop}` substitution, and prefixes `idPrefix`.

- `token_resolver.dart`  
  Resolves `@colors.*` → `Color`.

- `viewport_clipper.dart`  
  Clips to `meta.viewport` using `CustomClipper<Rect>`.

- `widget_factory.dart`  
  Maps `type` → Flutter widget.

- `recipe_screen_widget.dart`  
  Public widget:
  `RecipeScreenWidget(screenName: 'main', orientation: RecipeOrientation.auto, onAction: ...)`

---

## 3) Screen integration (minimal disruption)

Keep your existing UI files, but turn them into thin wrappers over the renderer:

- `lib/ui/launch_screen.dart`  
  Render `launch.(portrait|landscape)`.

- `lib/ui/main_screen.dart`  
  Render `main.(portrait|landscape)`.

- `lib/ui/session_screen.dart`  
  Switch among:
  - `countdown.(portrait|landscape)`
  - `active_session.(portrait|landscape)`
  - `rest.(portrait|landscape)`
  based on `SessionController` state.

- `lib/ui/end_screen.dart`  
  Render `summary.(portrait|landscape)`.

Keep these as non-recipe (for now), unless/when you add recipes for them:
- `lib/ui/settings_screen.dart`
- `lib/ui/history_screen.dart`

---

## 4) Coordinate system

- Artboard is **768×1024** logical px.
- `frame: {x,y,w,h}` uses artboard coordinates, origin (0,0) top-left.

### Viewport
- Use `meta.viewport` for clipping:
  - Portrait: usually full artboard.
  - Landscape: centered 768×576 region (y=224..800).
- Clip in artboard space, then apply scaling.

---

## 5) Scaling to real devices (deterministic)

Use *contain* scaling to preserve aspect ratio:

- `sx = constraints.maxWidth / 768`
- `sy = constraints.maxHeight / 1024`
- `s = min(sx, sy)`

Render:
- `Center(child: Transform.scale(scale: s, child: SizedBox(768×1024, child: ClipRect(...))))`

> Do not apply SafeArea padding unless a recipe explicitly includes it. This keeps pixel matching exact.

---

## 6) Render order (strict)

1) Start with `screen.elements[]` in order.
2) Expand each `screen.uses[]` in order and append their generated elements.
3) Later elements draw on top.

---

## 7) Token resolution (strict)

- Resolve `@colors.<name>` using `tokens.yaml.colors.<name>`.
- Everything else is literal.
- Special literal paints:
  - `"transparent"` / `"none"` → `Colors.transparent`.

---

## 8) Element → Flutter mapping (strict)

All elements are positioned absolutely in a Stack:

- `Stack(children: elements.map((e) => Positioned(...)).toList())`

### 8.1 rect
Recipe:
```yaml
type: rect
frame: {x,y,w,h}
style: {fill, stroke, strokeWidth, radius}
```

Flutter:
- `Positioned(left:x, top:y, width:w, height:h)`
- `DecoratedBox(BoxDecoration(color, borderRadius, border))`

Rules:
- stroke without strokeWidth → width 1.

### 8.2 text
Recipe:
```yaml
type: text
text: "Line1\nLine2"
style: {fontSize, fontWeight, color, align, lineHeight?, valign?}
```

Flutter:
- `Text(text, textAlign: ...)`
- Put inside:
  - `SizedBox(w,h)` then
  - `Align(alignment: ...)` (horizontal) and
  - optional `Center` if `valign: middle`.

Rules:
- `fontWeight` numeric (100..900) → nearest `FontWeight.w*`.
- `lineHeight` → `TextStyle(height: lineHeight/fontSize)`.

### 8.3 button
Recipe:
```yaml
type: button
text: "PLAY"
style: {fill, radius, textStyle:{fontSize,fontWeight,color}}
onTap: "session.start"
```

Flutter:
- `Material(color: Colors.transparent)`
- `InkWell(onTap: ..., borderRadius: ...)`
- Inner `Container` with background + radius
- Centered `Text`.

### 8.4 icon (Material Symbols)
Recipe:
```yaml
type: icon
asset: "icon:settings"
style: {color}
```

Flutter (preferred order):
1) Use built-in symbols (if available): `Icon(Symbols.settings, ...)`
2) Else use a package (e.g. `material_symbols_icons`) and map: `SymbolIcon(Symbols.settings, ...)`

Mapping rule:
- `asset: "icon:<name>"` → symbol name `<name>`.

If the symbol is missing:
- fallback to nearest `Icons.*`, but log/warn once.

### 8.5 image
Recipe:
```yaml
type: image
asset: "assets/logo_ball.png"
```
Flutter:
- `Image.asset(asset, fit: BoxFit.contain)`.

### 8.6 progress_ring
Recipe:
```yaml
type: progress_ring
style: {strokeWidth, trackColor, progressColor, progress?}
```

Flutter:
- `CustomPaint(painter: RingPainter(...))`
- Default `progress=0.75` for previews if not provided.

---

## 9) Keys (for golden tests + stability)

Every element with `id` must produce a stable key:
- `Key('recipe:<screen>:<orientation>:<id>')`

Example:
- `Key('recipe:main:portrait:nav.settingsIcon')`

---

## 10) Action routing (strings → real app behavior)

Do not embed navigation logic in the renderer. Instead the renderer emits actions upward.

### Action handler placement
Add an action dispatcher in:
- `lib/app.dart` (recommended) OR
- `lib/ui/widgets/recipe_renderer/recipe_actions.dart`

### Required mappings for your app
- `nav.settings` → navigate to `SettingsScreen`
- `nav.backToMenu` → navigate to `MainScreen`
- `session.start` → `SessionController.start()`
- `session.restart` → `SessionController.restart()` (or reset + start)
- `app.exit` → Android: `SystemNavigator.pop()`; iOS: no-op or confirm dialog

Navigation style should match your existing approach in `app.dart`.

---

## 11) Golden tests (recommended)

Add at least:
- main portrait
- main landscape
- active_session portrait

Suggested file:
- `test/goldens/recipe_screens_golden_test.dart`

Make the tests render a fixed size surface (e.g. `SurfaceSize(768,1024)`) and compare.

---

## 12) Implementation scope for the agent

1) Add recipes under `assets/ui_recipes/`.
2) Add renderer under `lib/ui/widgets/recipe_renderer/`.
3) Refactor:
   - `launch_screen.dart`, `main_screen.dart`, `session_screen.dart`, `end_screen.dart`
   to use `RecipeScreenWidget`.
4) Wire action dispatcher to `SessionController` and navigation in `app.dart`.
5) Add golden tests.

No other architectural refactors unless necessary.

