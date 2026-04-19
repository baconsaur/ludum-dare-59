extends Node2D

@onready var map = $HUD/Map
@onready var scan_line = $HUD/UI/ScanDisplay/ScanSignals


func _ready() -> void:
	init_map()

func init_map():
	map.initialize()
	map.connect("scanned", display_scan)

func display_scan(results, scan_radius):
	scan_line.update_signals(results, scan_radius)
