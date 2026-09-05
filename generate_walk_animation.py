#!/usr/bin/env python3
"""
生成 Mori 的 chibi 风格行走动画
Generate Mori's chibi-style walk animation frames
"""

from PIL import Image, ImageDraw
import os

# 颜色定义
YELLOW_JACKET = (255, 220, 80)
YELLOW_DARK = (230, 190, 50)
BROWN_HAIR = (139, 90, 43)
BROWN_DARK = (101, 67, 33)
SKIN_COLOR = (255, 220, 177)
SKIN_SHADOW = (235, 190, 147)
BLACK = (30, 30, 30)
PANTS_BLUE = (70, 100, 140)
SHOES_BROWN = (90, 60, 40)

SPRITE_SIZE = 64
HALF_SIZE = SPRITE_SIZE // 2

def create_base_body(draw, offset_x=0, offset_y=0):
    head_x = HALF_SIZE + offset_x
    head_y = 18 + offset_y
    head_radius = 12
    draw.ellipse([head_x - head_radius, head_y - head_radius,
                  head_x + head_radius, head_y + head_radius],
                 fill=SKIN_COLOR, outline=BLACK, width=2)
    body_top = head_y + head_radius
    body_bottom = body_top + 18
    body_width = 16
    draw.rectangle([head_x - body_width//2, body_top,
                   head_x + body_width//2, body_bottom],
                  fill=YELLOW_JACKET, outline=BLACK, width=2)
    draw.line([head_x, body_top, head_x, body_bottom],
             fill=YELLOW_DARK, width=2)
    pants_bottom = body_bottom + 8
    draw.rectangle([head_x - body_width//2, body_bottom,
                   head_x + body_width//2, pants_bottom],
                  fill=PANTS_BLUE, outline=BLACK, width=2)
    return head_x, head_y, body_bottom, pants_bottom

def draw_face_down(draw, head_x, head_y):
    draw.ellipse([head_x - 5, head_y - 2, head_x - 2, head_y + 1], fill=BLACK)
    draw.ellipse([head_x + 2, head_y - 2, head_x + 5, head_y + 1], fill=BLACK)
    draw.arc([head_x - 3, head_y + 3, head_x + 3, head_y + 7],
            start=0, end=180, fill=BLACK, width=2)

def draw_face_up(draw, head_x, head_y):
    draw.ellipse([head_x - 10, head_y - 12, head_x + 10, head_y + 4],
                fill=BROWN_HAIR, outline=BLACK, width=2)

def draw_face_side(draw, head_x, head_y, flip=False):
    offset = -3 if not flip else 3
    eye_x = head_x + offset
    draw.ellipse([eye_x - 2, head_y - 2, eye_x + 1, head_y + 1], fill=BLACK)
    nose_x = head_x + (offset + 2 if not flip else offset - 2)
    draw.line([nose_x, head_y + 1, nose_x, head_y + 3], fill=BLACK, width=1)

def draw_hair_down(draw, head_x, head_y):
    draw.ellipse([head_x - 12, head_y - 14, head_x + 12, head_y - 2],
                fill=BROWN_HAIR, outline=BLACK, width=2)
    draw.polygon([
        (head_x - 8, head_y - 6), (head_x - 4, head_y - 2),
        (head_x, head_y - 4), (head_x + 4, head_y - 2),
        (head_x + 8, head_y - 6)
    ], fill=BROWN_HAIR, outline=BLACK)

def draw_hair_up(draw, head_x, head_y):
    draw.ellipse([head_x - 12, head_y - 14, head_x + 12, head_y + 4],
                fill=BROWN_HAIR, outline=BLACK, width=2)

def draw_hair_side(draw, head_x, head_y, flip=False):
    if not flip:
        draw.ellipse([head_x - 12, head_y - 14, head_x + 10, head_y - 2],
                    fill=BROWN_HAIR, outline=BLACK, width=2)
    else:
        draw.ellipse([head_x - 10, head_y - 14, head_x + 12, head_y - 2],
                    fill=BROWN_HAIR, outline=BLACK, width=2)

def draw_arms(draw, head_x, body_top, body_bottom, side=False):
    arm_y = body_top + 5
    if not side:
        draw.line([head_x - 8, arm_y, head_x - 12, arm_y + 8],
                 fill=YELLOW_JACKET, width=5)
        draw.line([head_x - 8, arm_y, head_x - 12, arm_y + 8],
                 fill=BLACK, width=2)
        draw.line([head_x + 8, arm_y, head_x + 12, arm_y + 8],
                 fill=YELLOW_JACKET, width=5)
        draw.line([head_x + 8, arm_y, head_x + 12, arm_y + 8],
                 fill=BLACK, width=2)
    else:
        draw.line([head_x + 8, arm_y, head_x + 10, arm_y + 8],
                 fill=YELLOW_JACKET, width=5)
        draw.line([head_x + 8, arm_y, head_x + 10, arm_y + 8],
                 fill=BLACK, width=2)

def draw_legs_walk(draw, head_x, pants_bottom, frame, direction='down'):
    leg_length = 12
    leg_width = 4
    if frame == 0:
        left_offset, right_offset = 4, -4
    elif frame == 1:
        left_offset, right_offset = 0, 0
    elif frame == 2:
        left_offset, right_offset = -4, 4
    else:
        left_offset, right_offset = 0, 0
    left_x = head_x - 4
    draw.line([left_x, pants_bottom, left_x + left_offset, pants_bottom + leg_length],
             fill=PANTS_BLUE, width=leg_width)
    draw.ellipse([left_x + left_offset - 3, pants_bottom + leg_length - 2,
                 left_x + left_offset + 3, pants_bottom + leg_length + 2],
                fill=SHOES_BROWN, outline=BLACK, width=1)
    right_x = head_x + 4
    draw.line([right_x, pants_bottom, right_x + right_offset, pants_bottom + leg_length],
             fill=PANTS_BLUE, width=leg_width)
    draw.ellipse([right_x + right_offset - 3, pants_bottom + leg_length - 2,
                 right_x + right_offset + 3, pants_bottom + leg_length + 2],
                fill=SHOES_BROWN, outline=BLACK, width=1)

def draw_legs_idle(draw, head_x, pants_bottom):
    leg_length = 12
    leg_width = 4
    left_x = head_x - 4
    draw.line([left_x, pants_bottom, left_x, pants_bottom + leg_length],
             fill=PANTS_BLUE, width=leg_width)
    draw.ellipse([left_x - 3, pants_bottom + leg_length - 2,
                 left_x + 3, pants_bottom + leg_length + 2],
                fill=SHOES_BROWN, outline=BLACK, width=1)
    right_x = head_x + 4
    draw.line([right_x, pants_bottom, right_x, pants_bottom + leg_length],
             fill=PANTS_BLUE, width=leg_width)
    draw.ellipse([right_x - 3, pants_bottom + leg_length - 2,
                 right_x + 3, pants_bottom + leg_length + 2],
                fill=SHOES_BROWN, outline=BLACK, width=1)

def generate_sprite(direction, frame, idle=False):
    img = Image.new('RGBA', (SPRITE_SIZE, SPRITE_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    head_x, head_y, body_bottom, pants_bottom = create_base_body(draw)
    if direction == 'down':
        draw_hair_down(draw, head_x, head_y)
        draw_face_down(draw, head_x, head_y)
        draw_arms(draw, head_x, head_y + 12, body_bottom, side=False)
        if idle:
            draw_legs_idle(draw, head_x, pants_bottom)
        else:
            draw_legs_walk(draw, head_x, pants_bottom, frame, 'down')
    elif direction == 'up':
        draw_hair_up(draw, head_x, head_y)
        draw_face_up(draw, head_x, head_y)
        draw_arms(draw, head_x, head_y + 12, body_bottom, side=False)
        if idle:
            draw_legs_idle(draw, head_x, pants_bottom)
        else:
            draw_legs_walk(draw, head_x, pants_bottom, frame, 'up')
    elif direction == 'left':
        draw_hair_side(draw, head_x, head_y, flip=False)
        draw_face_side(draw, head_x, head_y, flip=False)
        draw_arms(draw, head_x, head_y + 12, body_bottom, side=True)
        if idle:
            draw_legs_idle(draw, head_x, pants_bottom)
        else:
            draw_legs_walk(draw, head_x, pants_bottom, frame, 'left')
    elif direction == 'right':
        draw_hair_side(draw, head_x, head_y, flip=True)
        draw_face_side(draw, head_x, head_y, flip=True)
        draw_arms(draw, head_x, head_y + 12, body_bottom, side=True)
        if idle:
            draw_legs_idle(draw, head_x, pants_bottom)
        else:
            draw_legs_walk(draw, head_x, pants_bottom, frame, 'right')
    return img

def main():
    output_dir = 'assets/player'
    os.makedirs(output_dir, exist_ok=True)
    print("生成 Mori 行走动画...")
    print("Generating Mori walk animation...")
    print("  - idle.png")
    idle_img = generate_sprite('down', 0, idle=True)
    idle_img.save(os.path.join(output_dir, 'idle.png'))
    directions = ['down', 'up', 'left', 'right']
    for direction in directions:
        for frame in range(4):
            filename = f'walk_{direction}_{frame}.png'
            print(f"  - {filename}")
            img = generate_sprite(direction, frame, idle=False)
            img.save(os.path.join(output_dir, filename))
    print(f"\n✓ 生成完成！共 17 张图片保存到 {output_dir}/")
    print(f"✓ Generation complete! 17 images saved to {output_dir}/")
    print("\n验证 PNG 文件签名...")
    print("Verifying PNG signatures...")
    for filename in os.listdir(output_dir):
        if filename.endswith('.png'):
            filepath = os.path.join(output_dir, filename)
            with open(filepath, 'rb') as f:
                signature = f.read(8)
                expected = b'\x89PNG\r\n\x1a\n'
                if signature == expected:
                    print(f"  ✓ {filename} - Valid PNG")
                else:
                    print(f"  ✗ {filename} - Invalid signature: {signature.hex()}")

if __name__ == '__main__':
    main()
