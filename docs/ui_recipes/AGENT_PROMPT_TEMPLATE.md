# AI Coding Agent Prompt (repo-tailored)

You are implementing UI in a Flutter app with this structure:

- `lib/controllers/session_controller.dart` (session state)
- `lib/services/*` (audio, history, scheduler)
- `lib/ui/*_screen.dart` (screens)
- `lib/ui/widgets/*` (reusable widgets)

The UI is specified by **UI recipes** stored under:
- `assets/ui_recipes/tokens.yaml`
- `assets/ui_recipes/components.yaml`
- `assets/ui_recipes/screens/*.yaml`

You MUST follow `docs/ui_recipes/AGENT_CONTRACT_UI_RECIPES.md`.

## Hard rules
- Do NOT redesign the UI.
- Match recipe geometry exactly (absolute positioning + deterministic scaling).
- Implement icons as **Material Symbols** from `icon:<name>`.
- All recipe element IDs become stable Flutter Keys.

## Tasks (in order)
1) Add recipe assets to `pubspec.yaml` and verify loading works.
2) Implement the recipe renderer under `lib/ui/widgets/recipe_renderer/`:
   - load YAML
   - expand components (`uses`)
   - resolve `@colors.*`
   - clip to `meta.viewport`
   - scale artboard (contain)
   - build a Stack of Positioned widgets
3) Update screens to use the renderer:
   - `lib/ui/launch_screen.dart` → launch recipe
   - `lib/ui/main_screen.dart` → main recipe (settings top-right, exit top-left)
   - `lib/ui/session_screen.dart` → countdown/active/rest recipes based on `SessionController`
   - `lib/ui/end_screen.dart` → summary recipe
4) Implement an action dispatcher in `lib/app.dart` (or `lib/ui/widgets/recipe_renderer/recipe_actions.dart`)
   mapping recipe `onTap` strings to:
   - navigation (settings, backToMenu)
   - session controller calls (start/restart)
   - app exit (`SystemNavigator.pop()` on Android)
5) Add golden tests for at least:
   - main portrait, main landscape, active_session portrait

## Deliverables
- New renderer files in `lib/ui/widgets/recipe_renderer/`
- Updated screen files listed above
- Golden test(s)
- Short README in `docs/ui_recipes/` describing how to add/modify recipes
