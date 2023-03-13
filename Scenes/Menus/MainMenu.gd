extends Control

signal continuegame
signal newgame

func _ready() -> void:
	$VBoxContainer/Continue.disabled = true
	$VBoxContainer/LevelSelect.disabled = true
	if SceneManager.completed_levels_data.size() > 0:
		$VBoxContainer/Continue.disabled = false
		$VBoxContainer/LevelSelect.disabled = false
	if SceneManager.all_levels_completed():
		$VBoxContainer/Continue.disabled = true
	$Audio.pressed = true

func _physics_process(delta: float) -> void:
	var mouse_pos = (get_global_mouse_position() - get_viewport().size/2)/(get_viewport().size/2)
	$ParallaxBackground.scroll_offset = mouse_pos * 10


func _on_Quit_pressed() -> void:
	SceneManager.export_savedata()
	get_tree().quit()


func _on_Continue_pressed() -> void:
	SceneManager._start_next_level()

func _on_Settings_pressed() -> void:
	SceneManager._open_settings()

func _on_NewGame_pressed() -> void:
	SceneManager._start_new_game()


func _on_LevelSelect_pressed() -> void:
	SceneManager._open_level_select()


func _on_Controls_pressed() -> void:
	SceneManager._open_controls()


func _on_Audio_pressed() -> void:
	$Audio.pressed = true
