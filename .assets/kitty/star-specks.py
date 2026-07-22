import random
import sys
from math import exp, sqrt

from PIL import Image, ImageColor


MAX_DOT_OPACITY = 0.4
TEXTURE_OVERLAY_OPACITY = 0.10
MASK_THRESHOLD = 0.35
MASK_GAMMA = 4.0
WALK_MASK_THRESHOLD = 0.15
WALK_MASK_GAMMA = 1.5
WALK_DIRECTION_MOMENTUM = 2.0
STRAND_START_COLOR = "#base08"
STRAND_END_COLOR = "#base0A"
SPECK_COUNT = 1000
STRAND_LENGTH = 10
STRAND_CONTINUE_PROBABILITY = 0.60
SEED = 16940
DIRECTIONS = [
    (-1, -1),
    (0, -1),
    (1, -1),
    (-1, 0),
    (1, 0),
    (-1, 1),
    (0, 1),
    (1, 1),
]


def mask_strength(mask_value: int, mask_maximum: int) -> float:
    return normalized_mask_strength(mask_value, mask_maximum, MASK_THRESHOLD)


def normalized_mask_strength(
    mask_value: int,
    mask_maximum: int,
    threshold: float,
) -> float:
    normalized = mask_value / 255
    return max(
        0,
        (normalized - threshold) / (mask_maximum / 255 - threshold),
    )


def weighted_position(
    rng: random.Random,
    mask_pixels,
    mask_maximum: int,
    width: int,
    height: int,
    occupied: set[tuple[int, int]],
) -> tuple[int, int]:
    while True:
        x = rng.randrange(width)
        y = rng.randrange(height)
        if (x, y) in occupied:
            continue

        strength = mask_strength(mask_pixels[x, y], mask_maximum)
        if rng.random() < strength**MASK_GAMMA:
            return x, y


def place_strands(
    rng: random.Random,
    mask_pixels,
    mask_maximum: int,
    width: int,
    height: int,
) -> list[list[tuple[int, int]]]:
    strands: list[list[tuple[int, int]]] = []
    occupied: set[tuple[int, int]] = set()
    placed_count = 0

    while placed_count < SPECK_COUNT:
        current = weighted_position(
            rng,
            mask_pixels,
            mask_maximum,
            width,
            height,
            occupied,
        )
        strand = [current]
        occupied.add(current)
        placed_count += 1
        direction = rng.choice(DIRECTIONS)

        for _ in range(1, STRAND_LENGTH):
            if placed_count >= SPECK_COUNT:
                break
            if rng.random() >= STRAND_CONTINUE_PROBABILITY:
                break

            candidates: list[tuple[int, int]] = []
            weights: list[float] = []
            direction_length = sqrt(direction[0] ** 2 + direction[1] ** 2)

            for proposed_direction in DIRECTIONS:
                x = (current[0] + proposed_direction[0]) % width
                y = (current[1] + proposed_direction[1]) % height
                proposed = (x, y)

                if proposed in occupied:
                    continue

                strength = normalized_mask_strength(
                    mask_pixels[proposed],
                    mask_maximum,
                    WALK_MASK_THRESHOLD,
                )
                if strength == 0:
                    continue

                proposed_length = sqrt(
                    proposed_direction[0] ** 2 + proposed_direction[1] ** 2
                )
                alignment = (
                    direction[0] * proposed_direction[0]
                    + direction[1] * proposed_direction[1]
                ) / (direction_length * proposed_length)
                weight = strength**WALK_MASK_GAMMA * exp(
                    WALK_DIRECTION_MOMENTUM * alignment
                )
                candidates.append(proposed)
                weights.append(weight)

            if not candidates:
                break

            previous = current
            current = max(zip(candidates, weights), key=lambda candidate: candidate[1])[0]
            direction = (
                (current[0] - previous[0] + width // 2) % width - width // 2,
                (current[1] - previous[1] + height // 2) % height - height // 2,
            )
            strand.append(current)
            occupied.add(current)
            placed_count += 1

        strands.append(strand)

    return strands


def interpolate_color(
    start: tuple[int, int, int],
    end: tuple[int, int, int],
    progress: float,
) -> tuple[int, int, int]:
    return tuple(
        round(start_channel + (end_channel - start_channel) * progress)
        for start_channel, end_channel in zip(start, end)
    )


def main(mask_path: str, output_path: str) -> None:
    with Image.open(mask_path) as source:
        texture = source.convert("RGBA")
        alpha_mask = texture.getchannel("A")
        width, height = alpha_mask.size
        mask_maximum = alpha_mask.getextrema()[1]

    if mask_maximum / 255 <= MASK_THRESHOLD:
        raise ValueError("MASK_THRESHOLD removes the entire density mask")

    overlay_alpha = alpha_mask.point(
        lambda value: round(value * TEXTURE_OVERLAY_OPACITY)
    )
    texture.putalpha(overlay_alpha)
    image = texture
    pixels = image.load()
    mask_pixels = alpha_mask.load()
    rng = random.Random(SEED)
    start_color = ImageColor.getrgb(STRAND_START_COLOR)
    end_color = ImageColor.getrgb(STRAND_END_COLOR)
    alpha = round(255 * MAX_DOT_OPACITY)

    strands = place_strands(rng, mask_pixels, mask_maximum, width, height)
    for strand in strands:
        for index, position in enumerate(strand):
            progress = index / max(1, len(strand) - 1)
            red, green, blue = interpolate_color(start_color, end_color, progress)
            pixels[position] = (red, green, blue, alpha)

    image.save(output_path, optimize=True)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
