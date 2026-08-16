class_name TileView
extends Node2D

const TILES: Array[Texture2D] = [
	preload("res://assets/tiles/forest_a.png"),
	preload("res://assets/tiles/forest_b.png"),
]

func texture_at(cell: Vector2i) -> Texture2D:
	return TILES[(cell.x * 7 + cell.y * 3) % TILES.size()]

func _draw() -> void:
	for x in Map.GRID_SIZE.x:
		for y in Map.GRID_SIZE.y:
			var cell := Vector2i(x, y)
			draw_texture(texture_at(cell), Map.to_pixel(cell))
