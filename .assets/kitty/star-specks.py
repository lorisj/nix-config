import random
import sys
from math import exp, sqrt
from pathlib import Path
from typing import Optional

from PIL import Image, ImageColor


MAX_DOT_OPACITY = 0.35
TEXTURE_OVERLAY_OPACITY = 0.08
MASK_THRESHOLD = 0.35
MASK_GAMMA = 4.0
WALK_MASK_THRESHOLD = 0.15
WALK_MASK_GAMMA = 1.5
WALK_DIRECTION_MOMENTUM = 2.0
STRAND_START_COLOR = "#base08"
STRAND_END_COLOR = "#base0A"
SPECK_COUNT = 500
STRAND_LENGTH = 10
STRAND_CONTINUE_PROBABILITY = 0.60
SEED = 16940
ANIMATION_FRAME_COUNT = 80
ANIMATION_STRAND_LENGTH = STRAND_LENGTH * 4
ANIMATION_SPECK_COUNT = SPECK_COUNT * 4
ANIMATION_STRAND_CONTINUE_PROBABILITY = 1.0
# The old 60% continuation chance makes a nominal ten-pixel strand only 2.5
# pixels long on average. A ten-pixel pulse is therefore roughly four times
# the previously visible average, while the forty-pixel path gives it room to
# follow the feather texture.
ANIMATION_PULSE_SPACING = 14.0
ANIMATION_PULSE_RISE = 2.0
ANIMATION_PULSE_TAIL = 8.0
ANIMATION_CYCLES_PER_LOOP = 2
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
    speck_count: int = SPECK_COUNT,
    strand_length: int = STRAND_LENGTH,
    continue_probability: float = STRAND_CONTINUE_PROBABILITY,
) -> list[list[tuple[int, int]]]:
    strands: list[list[tuple[int, int]]] = []
    occupied: set[tuple[int, int]] = set()
    placed_count = 0

    while placed_count < speck_count:
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

        for _ in range(1, strand_length):
            if placed_count >= speck_count:
                break
            if rng.random() >= continue_probability:
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


def smoothstep(progress: float) -> float:
    return progress * progress * (3 - 2 * progress)


def pulse_opacity(distance_behind_head: float) -> float:
    if distance_behind_head < ANIMATION_PULSE_RISE:
        return smoothstep(distance_behind_head / ANIMATION_PULSE_RISE)

    tail_progress = (
        distance_behind_head - ANIMATION_PULSE_RISE
    ) / ANIMATION_PULSE_TAIL
    if tail_progress < 1:
        return 1 - smoothstep(tail_progress)
    return 0


def generate_animation(
    background: Image.Image,
    strands: list[list[tuple[int, int]]],
    start_color: tuple[int, int, int],
    end_color: tuple[int, int, int],
    maximum_alpha: int,
    output_directory: str,
) -> None:
    output = Path(output_directory)
    output.mkdir(parents=True, exist_ok=True)
    phase_rng = random.Random(SEED + 2)
    strand_phases = [
        phase_rng.random() * ANIMATION_PULSE_SPACING for _ in strands
    ]

    for frame in range(ANIMATION_FRAME_COUNT):
        image = background.copy()
        pixels = image.load()
        travel = (
            ANIMATION_PULSE_SPACING
            * ANIMATION_CYCLES_PER_LOOP
            * frame
            / ANIMATION_FRAME_COUNT
        )

        for strand, phase in zip(strands, strand_phases):
            head = phase + travel
            for index, position in enumerate(strand):
                distance = (head - index) % ANIMATION_PULSE_SPACING
                opacity = pulse_opacity(distance)
                if opacity == 0:
                    continue

                progress = index / max(1, len(strand) - 1)
                red, green, blue = interpolate_color(
                    start_color,
                    end_color,
                    progress,
                )
                pixels[position] = (
                    red,
                    green,
                    blue,
                    round(maximum_alpha * opacity),
                )

        image.save(output / f"frame-{frame:02d}.png", optimize=True)


def main(
    mask_path: str,
    output_path: str,
    animation_output_directory: Optional[str] = None,
) -> None:
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
    animation_background = texture.copy()
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
    if animation_output_directory is not None:
        animation_strands = place_strands(
            random.Random(SEED + 1),
            mask_pixels,
            mask_maximum,
            width,
            height,
            speck_count=ANIMATION_SPECK_COUNT,
            strand_length=ANIMATION_STRAND_LENGTH,
            continue_probability=ANIMATION_STRAND_CONTINUE_PROBABILITY,
        )
        generate_animation(
            animation_background,
            animation_strands,
            start_color,
            end_color,
            alpha,
            animation_output_directory,
        )


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else None)
