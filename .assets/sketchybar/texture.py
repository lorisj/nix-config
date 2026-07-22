import random
import sys

from PIL import Image, ImageOps


WIDTH = 4096
HEIGHT = 38
ALPHA_MULTIPLIER = 5.0
SEED = 8675


def main(source_path: str, output_path: str) -> None:
    with Image.open(source_path) as source_file:
        source = source_file.convert("RGBA")

    source.putalpha(
        source.getchannel("A").point(
            lambda value: min(255, round(value * ALPHA_MULTIPLIER))
        )
    )

    output = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    rng = random.Random(SEED)

    for x in range(0, WIDTH, source.width):
        max_y = max(0, source.height - HEIGHT)
        y = rng.randrange(max_y + 1)
        tile = source.crop((0, y, source.width, y + HEIGHT))
        if (x // source.width) % 2:
            tile = ImageOps.mirror(tile)
        output.alpha_composite(tile, (x, 0))

    output.save(output_path, optimize=True)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
