#!/usr/bin/env python3
import math
import cairo

WIDTH, HEIGHT = 512, 512

surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, WIDTH, HEIGHT)
ctx = cairo.Context(surface)

# Clear background (transparent)
ctx.set_operator(cairo.OPERATOR_CLEAR)
ctx.paint()
ctx.set_operator(cairo.OPERATOR_OVER)

cx, cy = WIDTH / 2, HEIGHT / 2
radius = 210

# 1. Subtle glowing outer hexagon ring
def draw_hexagon(ctx, cx, cy, r):
    ctx.new_path()
    for i in range(6):
        angle = math.radians(60 * i - 30)
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        if i == 0:
            ctx.move_to(x, y)
        else:
            ctx.line_to(x, y)
    ctx.close_path()

# Outer Hexagon Path - Soft Royal Blue Gradient Border
draw_hexagon(ctx, cx, cy, radius)
pat = cairo.LinearGradient(cx - radius, cy - radius, cx + radius, cy + radius)
pat.add_color_stop_rgba(0.0, 0.11, 0.38, 0.94, 0.15)  # Royal Blue (#1D4ED8)
pat.add_color_stop_rgba(1.0, 0.02, 0.59, 0.41, 0.20)  # Emerald (#059669)
ctx.set_source(pat)
ctx.fill_preserve()

ctx.set_line_width(8)
pat_stroke = cairo.LinearGradient(cx - radius, cy - radius, cx + radius, cy + radius)
pat_stroke.add_color_stop_rgba(0.0, 0.11, 0.38, 0.94, 0.9)  # Royal Blue
pat_stroke.add_color_stop_rgba(0.5, 0.14, 0.65, 0.60, 0.9)  # Cyan/Teal blend
pat_stroke.add_color_stop_rgba(1.0, 0.02, 0.59, 0.41, 0.95) # Emerald
ctx.set_source(pat_stroke)
ctx.stroke()

# Inner Hexagon accent
draw_hexagon(ctx, cx, cy, radius - 24)
ctx.set_line_width(2)
ctx.set_source_rgba(0.11, 0.38, 0.94, 0.3)
ctx.stroke()

# 2. Dynamic Orbiting Elliptical Thread Loops (Textile Spin Rings)
ctx.save()
ctx.translate(cx, cy)
ctx.rotate(math.radians(-28))

# Outer Thread Orbit
ctx.new_path()
ctx.scale(1.0, 0.36)
ctx.arc(0, 0, 160, 0, 2 * math.pi)
ctx.restore()

ctx.set_line_width(6)
pat_orbit1 = cairo.LinearGradient(cx - 150, cy, cx + 150, cy)
pat_orbit1.add_color_stop_rgba(0.0, 0.11, 0.38, 0.94, 0.1)
pat_orbit1.add_color_stop_rgba(0.5, 0.02, 0.59, 0.41, 0.95)
pat_orbit1.add_color_stop_rgba(1.0, 0.11, 0.38, 0.94, 0.3)
ctx.set_source(pat_orbit1)
ctx.stroke()

# Second Crossing Thread Orbit
ctx.save()
ctx.translate(cx, cy)
ctx.rotate(math.radians(28))
ctx.new_path()
ctx.scale(1.0, 0.36)
ctx.arc(0, 0, 160, 0, 2 * math.pi)
ctx.restore()

ctx.set_line_width(4)
pat_orbit2 = cairo.LinearGradient(cx - 150, cy, cx + 150, cy)
pat_orbit2.add_color_stop_rgba(0.0, 0.02, 0.59, 0.41, 0.2)
pat_orbit2.add_color_stop_rgba(0.5, 0.11, 0.38, 0.94, 0.85)
pat_orbit2.add_color_stop_rgba(1.0, 0.02, 0.59, 0.41, 0.2)
ctx.set_source(pat_orbit2)
ctx.stroke()

# 3. Modern Stylized Central "S" Spindle Monogram
ctx.new_path()
# We draw a high precision geometric 'S' ribbon
# Upper loop of S
ctx.move_to(cx + 65, cy - 100)
ctx.curve_to(cx + 65, cy - 145, cx - 65, cy - 145, cx - 65, cy - 85)
ctx.curve_to(cx - 65, cy - 25, cx + 70, cy - 15, cx + 70, cy + 60)
ctx.curve_to(cx + 70, cy + 135, cx - 70, cy + 135, cx - 70, cy + 85)

ctx.set_line_cap(cairo.LINE_CAP_ROUND)
ctx.set_line_join(cairo.LINE_JOIN_ROUND)
ctx.set_line_width(32)

pat_s = cairo.LinearGradient(cx - 70, cy - 130, cx + 70, cy + 130)
pat_s.add_color_stop_rgb(0.0, 0.11, 0.38, 0.94)  # Deep Royal Blue (#1D4ED8)
pat_s.add_color_stop_rgb(0.5, 0.14, 0.65, 0.70)  # Modern Indigo/Teal
pat_s.add_color_stop_rgb(1.0, 0.02, 0.59, 0.41)  # Emerald Accent (#059669)
ctx.set_source(pat_s)
ctx.stroke()

# Inner thread highlight core along the S
ctx.new_path()
ctx.move_to(cx + 65, cy - 100)
ctx.curve_to(cx + 65, cy - 145, cx - 65, cy - 145, cx - 65, cy - 85)
ctx.curve_to(cx - 65, cy - 25, cx + 70, cy - 15, cx + 70, cy + 60)
ctx.curve_to(cx + 70, cy + 135, cx - 70, cy + 135, cx - 70, cy + 85)
ctx.set_line_width(8)
ctx.set_source_rgba(1.0, 1.0, 1.0, 0.75)
ctx.stroke()

# 4. Spindle Nodes / Accents
def draw_node(ctx, x, y, r, r_col, g_col, b_col):
    ctx.arc(x, y, r, 0, 2 * math.pi)
    ctx.set_source_rgb(r_col, g_col, b_col)
    ctx.fill_preserve()
    ctx.set_line_width(3)
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.stroke()

# Top anchor node
draw_node(ctx, cx + 65, cy - 100, 14, 0.11, 0.38, 0.94)
# Bottom anchor node
draw_node(ctx, cx - 70, cy + 85, 14, 0.02, 0.59, 0.41)
# Center junction node
draw_node(ctx, cx, cy, 10, 0.14, 0.65, 0.70)

surface.write_to_png('/home/muqeet/Desktop/spinning-calculator/assets/images/logo.png')
print("Successfully generated modern hexagonal Spin Logic emblem at assets/images/logo.png")
