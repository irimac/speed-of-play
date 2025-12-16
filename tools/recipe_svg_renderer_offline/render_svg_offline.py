# render_svg_offline.py
#
# Usage:
#   python render_svg_offline.py screens/main.portrait.yaml out/main.portrait.svg
#
# Renders UI recipe YAML to SVG.
# - Expands components.yaml `uses`
# - Resolves @colors.* from tokens.yaml
# - Renders `type: icon` using Material Symbols Outlined ligature text
# - INLINES the Material Symbols Outlined WOFF2 font into the SVG (offline-capable)

from __future__ import annotations
import base64
import math
import re
import sys
from copy import deepcopy
from pathlib import Path

import yaml
import svgwrite

PLACEHOLDER = re.compile(r"\$\{([^}]+)\}")

def load_yaml(path: Path):
    return yaml.safe_load(path.read_text(encoding="utf-8"))

def resolve_colors(value, tokens: dict):
    if isinstance(value, str) and value.startswith("@colors."):
        return tokens["colors"][value.split(".", 1)[1]]
    return value

def deep_resolve_colors(obj, tokens: dict):
    if isinstance(obj, str):
        return resolve_colors(obj, tokens)
    if isinstance(obj, list):
        return [deep_resolve_colors(x, tokens) for x in obj]
    if isinstance(obj, dict):
        return {k: deep_resolve_colors(v, tokens) for k, v in obj.items()}
    return obj

def substitute(obj, props: dict):
    if isinstance(obj, str):
        return PLACEHOLDER.sub(lambda m: str(props.get(m.group(1), m.group(0))), obj)
    if isinstance(obj, list):
        return [substitute(x, props) for x in obj]
    if isinstance(obj, dict):
        return {k: substitute(v, props) for k, v in obj.items()}
    return obj

def expand_elements(screen: dict, components: dict):
    elems = deepcopy(screen.get("elements", []))
    for inst in (screen.get("uses") or []):
        comp = components["components"][inst["use"]]
        gen = substitute(deepcopy(comp["elements"]), inst.get("props", {}))
        prefix = inst.get("idPrefix", "") or ""
        if prefix:
            for e in gen:
                if "id" in e:
                    e["id"] = prefix + e["id"]
        elems.extend(gen)
    return elems

def normalize_paint(v):
    # svgwrite doesn't accept "transparent"
    if v == "transparent":
        return "none"
    return v

def ensure_offline_material_symbols(dwg: svgwrite.Drawing, font_b64: str):
    if getattr(dwg, "_ms_offline_added", False):
        return
    css = f"""@font-face {{
  font-family: "Material Symbols Outlined";
  font-style: normal;
  font-weight: 100 700;
  font-display: block;
  src: url("data:font/woff2;base64,{font_b64}") format("woff2");
}}
text.material-symbols-outlined {{
  font-family: "Material Symbols Outlined";
  font-variation-settings: "FILL" 0, "wght" 400, "GRAD" 0, "opsz" 48;
  font-feature-settings: "liga";
}}"""
    dwg.defs.add(dwg.style(css))
    dwg._ms_offline_added = True

def add_with_clip(dwg, el, clip_id: str | None):
    if clip_id:
        el.update({"clip-path": f"url(#{clip_id})"})
    dwg.add(el)

def draw_text(dwg, x, y, w, h, text, style, clip_id: str | None, *, font_family="Inter, Arial, sans-serif"):
    fill = normalize_paint(style.get("color", "#000"))
    fs = float(style.get("fontSize", 16))
    fw = style.get("fontWeight", 400)
    align = style.get("align", "left")
    valign = style.get("valign", None)
    lh = style.get("lineHeight", None)

    anchor = {"left":"start","center":"middle","right":"end"}.get(align, "start")
    tx = x if align=="left" else (x + w/2 if align=="center" else x + w)
    # baseline approx
    ty = (y + h/2) if valign == "middle" else (y + fs)

    t = dwg.text("", insert=(tx, ty), fill=fill)
    t.update({
        "text-anchor": anchor,
        "font-size": fs,
        "font-weight": fw,
        "font-family": font_family
    })

    lines = str(text).split("\n")
    if len(lines) == 1:
        t.add(dwg.tspan(lines[0]))
    else:
        step = float(lh) if lh is not None else fs * 1.1
        for i, line in enumerate(lines):
            t.add(dwg.tspan(line, x=[tx], dy=[0 if i==0 else step]))

    add_with_clip(dwg, t, clip_id)

def draw_material_symbol_icon(dwg, x, y, w, h, icon_name: str, color: str, clip_id: str | None, font_b64: str):
    ensure_offline_material_symbols(dwg, font_b64)
    cx, cy = x + w/2, y + h/2
    fs = min(w, h) * 0.95
    t = dwg.text(icon_name, insert=(cx, cy), fill=color)
    t.update({
        "text-anchor": "middle",
        "dominant-baseline": "central",
        "font-size": fs,
        "font-family": "Material Symbols Outlined",
        "font-weight": 400,
        "class": "material-symbols-outlined"
    })
    add_with_clip(dwg, t, clip_id)

def draw_element(dwg, e: dict, tokens: dict, clip_id: str | None, font_b64: str):
    t = e["type"]
    f = e["frame"]
    x, y, w, h = float(f["x"]), float(f["y"]), float(f["w"]), float(f["h"])
    style = deep_resolve_colors(e.get("style", {}) or {}, tokens)

    if t == "rect":
        fill = normalize_paint(style.get("fill", "none"))
        stroke = normalize_paint(style.get("stroke"))
        sw = style.get("strokeWidth")
        r = float(style.get("radius", 0) or 0)
        rect = dwg.rect(insert=(x, y), size=(w, h), rx=r, ry=r, fill=fill)
        if stroke: rect.update({"stroke": stroke})
        if sw is not None: rect.update({"stroke-width": sw})
        add_with_clip(dwg, rect, clip_id)

    elif t == "text":
        draw_text(dwg, x, y, w, h, e.get("text", ""), deep_resolve_colors(e.get("style", {}) or {}, tokens), clip_id)

    elif t == "image":
        href = e.get("asset", "")
        img = dwg.image(href=href, insert=(x, y), size=(w, h))
        add_with_clip(dwg, img, clip_id)

    elif t == "button":
        fill = normalize_paint(resolve_colors(style.get("fill", "#2E8E43"), tokens))
        r = float(style.get("radius", min(w, h)/2))
        add_with_clip(dwg, dwg.rect(insert=(x, y), size=(w, h), rx=r, ry=r, fill=fill), clip_id)
        ts = style.get("textStyle", {}) or {}
        draw_text(dwg, x, y + h*0.1, w, h, e.get("text", ""), {
            "fontSize": ts.get("fontSize", 32),
            "fontWeight": ts.get("fontWeight", 900),
            "color": ts.get("color", "#FFFFFF"),
            "align": "center",
            "valign": "middle",
        }, clip_id)

    elif t == "icon":
        asset = e.get("asset", "icon:help")
        icon_name = asset.replace("icon:", "")
        color = normalize_paint(resolve_colors(style.get("color", "#111111"), tokens))
        draw_material_symbol_icon(dwg, x, y, w, h, icon_name, color, clip_id, font_b64)

    elif t == "progress_ring":
        prog = float(style.get("progress", 0.75))
        sw = float(style.get("strokeWidth", 18))
        track = normalize_paint(resolve_colors(style.get("trackColor", "#ccc"), tokens))
        pc = normalize_paint(resolve_colors(style.get("progressColor", "#333"), tokens))
        cx, cy = x + w/2, y + h/2
        r = min(w, h)/2 - sw/2
        add_with_clip(dwg, dwg.circle(center=(cx, cy), r=r, fill="none", stroke=track, stroke_width=sw), clip_id)
        circ = 2 * math.pi * r
        dash = max(0.0, min(1.0, prog)) * circ
        gap = max(0.0, circ - dash)
        c = dwg.circle(center=(cx, cy), r=r, fill="none", stroke=pc, stroke_width=sw)
        c.update({"stroke-dasharray": f"{dash} {gap}", "transform": f"rotate(-90 {cx} {cy})"})
        add_with_clip(dwg, c, clip_id)

    elif t == "group":
        for ch in (e.get("children") or []):
            draw_element(dwg, ch, tokens, clip_id, font_b64)

def render(screen_file: Path, out_file: Path, font_file: Path):
    root = screen_file.parents[1]  # .../screens -> pack root
    tokens = load_yaml(root / "tokens.yaml")
    components = load_yaml(root / "components.yaml")
    screen = load_yaml(screen_file)

    # prepare font base64 once
    font_b64 = base64.b64encode(font_file.read_bytes()).decode("ascii")

    # expand + resolve colors
    elems = expand_elements(screen, components)
    elems = deep_resolve_colors(elems, tokens)

    art = screen["meta"]["artboard"]
    vp = screen["meta"]["viewport"]

    dwg = svgwrite.Drawing(str(out_file), size=(art["w"], art["h"]))

    # clip to viewport (important for landscape)
    clip_id = "viewportClip"
    cp = dwg.defs.add(dwg.clipPath(id=clip_id))
    cp.add(dwg.rect(insert=(vp["x"], vp["y"]), size=(vp["w"], vp["h"])))

    for e in elems:
        draw_element(dwg, e, tokens, clip_id, font_b64)

    dwg.save()

def main():
    if len(sys.argv) < 3:
        print("Usage: python render_svg_offline.py screens/main.portrait.yaml out/main.portrait.svg")
        sys.exit(1)

    screen_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # expects the font next to this script by default
    default_font = Path(__file__).parent / "material-symbols-outlined.woff2"
    if not default_font.exists():
        print(f"Missing font file: {default_font}")
        sys.exit(2)

    render(screen_path, out_path, default_font)

if __name__ == "__main__":
    main()
