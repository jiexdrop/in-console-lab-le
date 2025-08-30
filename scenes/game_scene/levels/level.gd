extends Node

signal level_lost
signal level_won
signal level_won_and_changed(level_path : String)

@export_file("*.tscn") var next_level_path : String

var level_state : LevelState

func _on_lose_button_pressed() -> void:
	level_lost.emit()

func _on_win_button_pressed() -> void:
	if not next_level_path.is_empty():
		level_won_and_changed.emit(next_level_path)
	else:
		level_won.emit()

func _ready() -> void:
	level_state = GameState.get_level_state(scene_file_path)
	#%ColorPickerButton.color = level_state.color
	#%BackgroundColor.color = level_state.color
	#if not level_state.tutorial_read:
	#	open_tutorials()
