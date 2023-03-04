extends Control

signal continuegame
signal newgame

func _ready() -> void:
	if SceneManager.levels_cleared.size() <= 0:
		$VBoxContainer/Continue.disabled = true

func _physics_process(delta: float) -> void:
	var mouse_pos = (get_global_mouse_position() - get_viewport().size/2)/(get_viewport().size/2)
	$ParallaxBackground.scroll_offset = mouse_pos * 10


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_Continue_pressed() -> void:
	SceneManager._start_next_level()

func _on_Settings_pressed() -> void:
	SceneManager._open_settings()

func _on_NewGame_pressed() -> void:
	SceneManager._start_new_game()


func _on_LevelSelect_pressed() -> void:
	SceneManager._open_level_select()
