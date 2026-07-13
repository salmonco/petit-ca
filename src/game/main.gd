extends Node2D

@onready var player: ColorRect = $Player

func _ready() -> void:
	player.size = Vector2.ONE * Map.CELL_SIZE
