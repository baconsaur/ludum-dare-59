extends Node2D
@export var map_width: int = 4
@export var map_height: int = 4

@onready var map = $HUD/Map


func _ready() -> void:
	init_map()

func init_map():
	map.initialize(map_width, map_height)
