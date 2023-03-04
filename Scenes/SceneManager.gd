extends Node2D




var level_1 = "res://Scenes/Levels/Level1.tscn"
var level_2 = "res://Scenes/Levels/Level2.tscn"
var levels: Array = [level_1, level_2]
var levels_cleared: Array = []
var current_level_index: int



var main_menu = "res://Scenes/Menus/MainMenu.tscn"

var level_cleared_menu = "res://Scenes/Menus/LevelClearedMenu.tscn"
var settings_menu = "res://Scenes/Menus/SettingsMenu.tscn"
var level_select_menu = "res://Scenes/Menus/LevelSelectMenu.tscn"
var background = "res://Scenes/ParallaxBackground.tscn"

var pause_menu = preload("res://Scenes/Menus/PauseMenu.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and get_tree().current_scene.is_in_group("Levels"):
		var pause_menu_instance = pause_menu.instance()
		get_tree().get_root().add_child(pause_menu_instance)


func load_scene(scene):
	var transition_scene = $Transition
	transition_scene.visible = true
	transition_scene.animation_player.play("fade_in")
	yield(transition_scene.animation_player, "animation_finished")
	get_tree().change_scene(scene)
	transition_scene.animation_player.play_backwards("fade_in")
	yield(transition_scene.animation_player, "animation_finished")
	transition_scene.visible = false

func _start_next_level() -> void:
	if current_level_index >= levels.size()-1:
		_return_to_menu()
		return
	current_level_index += 1
	load_scene(levels[current_level_index])

func _start_new_game() -> void:
	current_level_index = 0
	load_scene(levels[0])

func _resume_game() -> void:
	get_tree().paused = false

func _return_to_menu() -> void:
	get_tree().paused = false
	load_scene(main_menu)

func _restart_level() -> void:
	get_tree().paused = false
	load_scene(levels[current_level_index])

func _level_cleared(stats, perfect_stats) -> void:
	load_scene(level_cleared_menu)
	levels_cleared.append(levels[current_level_index])
	#wait until next frame, then update current scene
	#(level cleared scene)
	#or update it before?

func _level_failed(stats) -> void:
	var level_cleared_instance = level_cleared_menu.instance()
	level_cleared_instance.died = true
	load_scene(level_cleared_menu)

func _open_settings() -> void:
	load_scene(settings_menu)

func _open_level_select() -> void:
	load_scene(level_select_menu)
