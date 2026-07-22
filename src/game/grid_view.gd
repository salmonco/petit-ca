class_name GridView
extends Node2D

const LINE_COLOR := Color(1, 1, 1, 0.15)

func _draw() -> void:
	var cell := Map.PIXELS_PER_CELL
	var grid := Map.GRID_SIZE
	for x in range(grid.x + 1):
		draw_line(Vector2(x * cell, 0), Vector2(x * cell, grid.y * cell), LINE_COLOR)
	for y in range(grid.y + 1):
		draw_line(Vector2(0, y * cell), Vector2(grid.x * cell, y * cell), LINE_COLOR)
