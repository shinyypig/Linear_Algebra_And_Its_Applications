#!/usr/bin/env python3
"""Recover a straight-alpha PNG from black- and white-background renders."""

from pathlib import Path
import sys

from PIL import Image


def recover_alpha(black_path: Path, white_path: Path, output_path: Path) -> None:
    black = Image.open(black_path).convert("RGB")
    white = Image.open(white_path).convert("RGB")
    if black.size != white.size:
        raise ValueError(
            f"render sizes differ: {black.size!r} != {white.size!r}"
        )

    black_bytes = black.tobytes()
    white_bytes = white.tobytes()
    output = bytearray(black.width * black.height * 4)

    for pixel in range(black.width * black.height):
        source = pixel * 3
        target = pixel * 4
        background = max(
            white_bytes[source] - black_bytes[source],
            white_bytes[source + 1] - black_bytes[source + 1],
            white_bytes[source + 2] - black_bytes[source + 2],
        )
        alpha = max(0, min(255, 255 - background))

        if alpha:
            output[target] = min(
                255, round(black_bytes[source] * 255 / alpha)
            )
            output[target + 1] = min(
                255, round(black_bytes[source + 1] * 255 / alpha)
            )
            output[target + 2] = min(
                255, round(black_bytes[source + 2] * 255 / alpha)
            )
        output[target + 3] = alpha

    Image.frombytes("RGBA", black.size, bytes(output)).save(output_path)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(
            "usage: recover_asymptote_alpha.py BLACK.png WHITE.png OUTPUT.png"
        )
    recover_alpha(*(Path(argument) for argument in sys.argv[1:4]))
