extends Node2D

var current_level = 0
var total_score = 0

@onready var map = $HUD/MapContainer/Map
@onready var scan_line = $HUD/Scanner/ScanDisplay/ScanSignals
@onready var flag_display = $HUD/MarginContainer/Flags/FlagCount
@onready var end_level_prompt = $HUD/LevelEndPrompt
@onready var end_level_button = $HUD/LevelEndPrompt/EndLevel
@onready var next_level_prompt = $HUD/NextLevelPrompt
@onready var level_stats_label = $HUD/NextLevelPrompt/VBoxContainer/LevelStats
@onready var end_game_prompt = $HUD/EndGamePrompt
@onready var end_stats_label = $HUD/EndGamePrompt/VBoxContainer/EndStats
@onready var total_score_label = $HUD/Stats/Score
@onready var failed_level_prompt = $HUD/FailedLevelPrompt
@onready var failed_level_label = $HUD/FailedLevelPrompt/VBoxContainer/LevelStats

var map_data = [
	{
		"width": 4,
		"height": 3,
		"start_flags": 1,
		"scan_radius": 2,
	},
	{
		"width": 5,
		"height": 4,
		"start_flags": 2,
		"scan_radius": 2,
	},
	{
		"width": 6,
		"height": 5,
		"start_flags": 3,
		"scan_radius": 2,
	},
	{
		"width": 8,
		"height": 6,
		"start_flags": 3,
		"scan_radius": 3,
	},
	{
		"width": 10,
		"height": 8,
		"start_flags": 4,
		"scan_radius": 3,
	},
	{
		"width": 12,
		"height": 9,
		"start_flags": 4,
		"scan_radius": 4,
	},
	{
		"width": 15,
		"height": 10,
		"start_flags": 4,
		"scan_radius": 5,
	},
]

func _ready() -> void:
	map.connect("scanned", display_scan)
	map.connect("flags_updated", update_flags)
	init_map()

func init_map():
	scan_line.update_signals([], 0)
	total_score_label.text = str(total_score)
	end_level_button.visible = true
	end_level_button.disabled = true
	end_game_prompt.visible = false
	failed_level_prompt.visible = false
	next_level_prompt.visible = false
	map.initialize(map_data[current_level])

func display_scan(results, scan_radius):
	scan_line.update_signals(results, scan_radius)

func update_flags(num_flags):
	flag_display.text = str(num_flags)
	if num_flags <= 0:
		end_level_button.disabled = false
	else:
		end_level_button.disabled = true

func _on_end_level_pressed() -> void:
	end_level_button.disabled = true
	scan_line.update_signals([], 0)
	
	var map_score = await map.reveal_score()
	var score_text = "Score: " + str(map_score[0]) + "/" + str(map_score[1])
	var min_score = map.max_score / 2
	
	if map_score[0] >= min_score:
		next_level_prompt.visible = true
		level_stats_label.text = score_text
		total_score += map_score[0]
		total_score_label.text = str(total_score)
	else:
		failed_level_prompt.visible = true
		failed_level_label.text = score_text + "\nScore at least " + str(min_score) + " points to continue"
	
func _on_continue_pressed() -> void:
	next_level_prompt.visible = false
	
	if len(map_data) > current_level + 1:
		current_level += 1
		SceneManager.transition_before(init_map)
	else:
		end_stats_label.text = "Game Over\nTotal score: " + str(total_score)
		end_game_prompt.visible = true

func _on_end_game_pressed() -> void:
	SceneManager.transition_to("start_game")

func _on_retry_pressed() -> void:
	failed_level_prompt.visible = false
	SceneManager.transition_before(init_map)
