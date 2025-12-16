How to generate offline SVG previews
====================================

Install deps
------------
pip install pyyaml svgwrite

Render one
----------
python render_svg_offline.py screens/main.portrait.yaml out/main.portrait.svg

Render all (macOS/Linux)
------------------------
mkdir -p out
for f in screens/*.yaml; do
  base=$(basename "$f" .yaml)
  python render_svg_offline.py "$f" "out/${base}.svg"
done

Render all (Windows PowerShell)
-------------------------------
mkdir out
Get-ChildItem .\screens\*.yaml | ForEach-Object {
  $out = ".\out\" + $_.BaseName + ".svg"
  python .\render_svg_offline.py $_.FullName $out
}

Notes
-----
- `type: icon` + `asset: icon:<name>` is rendered using Material Symbols Outlined ligatures.
- The WOFF2 font is embedded directly into each SVG, so the SVG renders without network access.
