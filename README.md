SPEED OF PLAY — One-Stop Bundle
===============================

This zip contains everything needed to collaborate with an AI coding agent on implementing the app UI.

Recommended usage with your repo
--------------------------------
Repo: https://github.com/irimac/speed-of-play

Copy these folders into the repo:
- `assets/ui_recipes/`   (UI spec: tokens/components/screens)
- `docs/ui_recipes/`     (agent contract + prompt template)
Optional:
- `tools/recipe_svg_renderer_offline/` (generate SVG previews locally, offline)
- `mocks/derived_svgs_offline/`        (pre-generated offline SVG previews)

Then update `pubspec.yaml`:
  flutter:
    assets:
      - assets/ui_recipes/tokens.yaml
      - assets/ui_recipes/components.yaml
      - assets/ui_recipes/screens/

AI coding agent workflow
------------------------
1) Provide the agent:
   - `assets/ui_recipes/**`
   - `docs/ui_recipes/AGENT_CONTRACT_UI_RECIPES.md`
   - `docs/ui_recipes/AGENT_PROMPT_TEMPLATE.md`
2) The agent implements a renderer under:
   - `lib/ui/widgets/recipe_renderer/`
3) Your existing screens become thin wrappers that render recipes.

Offline SVG previews
--------------------
- Previews are in `mocks/derived_svgs_offline/`.
- To regenerate (offline icons included), see:
  `tools/recipe_svg_renderer_offline/RENDER_SVGS_OFFLINE.md`

Notes
-----
- Icons: `type: icon` + `asset: icon:<name>` are Material Symbols.
  The SVG previews embed the WOFF2 font directly, so they work offline.
- Landscape: viewport clipping (y=224..800) is required for perfect alignment.

