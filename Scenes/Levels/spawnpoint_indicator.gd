extends Node2D

const SIZE = 32.0
const COLOR_FILL = Color(0.0, 0.5, 1.0, 0.30)
const COLOR_BORDER = Color(0.0, 0.4, 1.0, 0.9)

func _draw():
	var rect = Rect2(Vector2(-SIZE / 2.0, -SIZE / 2.0), Vector2(SIZE, SIZE))
	draw_rect(rect, COLOR_FILL)
	draw_rect(rect, COLOR_BORDER, false, 2.0)
