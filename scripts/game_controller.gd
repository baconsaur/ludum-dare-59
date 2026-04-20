extends Node2D

@onready var map = $HUD/Map
@onready var scan_line = $HUD/Scanner/ScanDisplay/ScanSignals
@onready var flag_display = $HUD/Flags/FlagCount
@onready var end_level_prompt = $HUD/LevelEndPrompt
@onready var next_level_prompt = $HUD/NextLevelPrompt
@onready var score_display = $HUD/NextLevelPrompt/VBoxContainer/Score

func _ready() -> void:
	map.connect("scanned", display_scan)
	map.connect("flags_updated", update_flags)
	init_map()

func init_map():
	end_level_prompt.visible = false
	next_level_prompt.visible = false
	map.initialize()

func display_scan(results, scan_radius):
	scan_line.update_signals(results, scan_radius)

func update_flags(num_flags):
	flag_display.text = str(num_flags)
	if num_flags <= 0:
		end_level_prompt.visible = true
	else:
		end_level_prompt.visible = false

func _on_end_level_pressed() -> void:
	end_level_prompt.visible = false
	next_level_prompt.visible = true
	var map_score = map.reveal_score()
	score_display.text = "Score: " + str(int(ceil(map_score)))
	
func _on_next_level_pressed() -> void:
	SceneManager.transition_before(init_map)
