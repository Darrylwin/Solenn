"""Renders the PNG icons of assets/branding from their SVG sources.

The SVG files are the source of truth; every PNG is derived from one of them.
Usage, from the repository root:

    pip install cairosvg pillow
    python tool/branding/render_icons.py
"""

import io
from pathlib import Path

import cairosvg
from PIL import Image

BRANDING = Path("assets/branding")

# source svg -> (size in pixels, opaque). An opaque icon has no alpha channel,
# as the iOS icon requires.
OUTPUTS = {
    "icon-foreground": (1024, False),
    "icon-monochrome": (1024, False),
    "icon-ios": (1024, True),
    "icon-ios-dark": (1024, False),
    "icon-ios-tinted": (1024, True),
    "splash-mark": (1152, False),
}


def render(name: str, size: int, opaque: bool) -> None:
    png = cairosvg.svg2png(
        url=str(BRANDING / f"{name}.svg"),
        output_width=size,
        output_height=size,
    )
    image = Image.open(io.BytesIO(png))
    if opaque:
        image = image.convert("RGB")
    image.save(BRANDING / f"{name}.png", optimize=True)
    print(f"{name}.png  {size}x{size}  {'opaque' if opaque else 'alpha'}")


if __name__ == "__main__":
    for name, (size, opaque) in OUTPUTS.items():
        render(name, size, opaque)