extends Node2D




var level_1 = {"level":"res://Scenes/Levels/Level1.tscn", 
				"completed": false,
				"kills": 0,
				"damage taken": 0,
				"time": 0,
				"name": "level 1"
				}
var level_2 = {"level":"res://Scenes/Levels/Level2.tscn", 
				"completed": false,
				"kills": 0,
				"damage taken": 0,
				"time": 0,
				"name": "level 2"
				}
var levels: Array = [level_1, level_2]
var current_level_index: int



var main_menu = "res://Scenes/Menus/MainMenu.tscn"

var level_cleared_menu = "res://Scenes/Menus/LevelClearedMenu.tscn"
var level_failed_menu = "res://Scenes/Menus/LevelFailedMenu.tscn"
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
	load_scene(levels[current_level_index]["level"])

func _start_new_game() -> void:
	current_level_index = 0
	load_scene(levels[0]["level"])

func _enter_level(index) -> void:
	load_scene(levels[index]["level"])

func _resume_game() -> void:
	get_tree().paused = false

func _return_to_menu() -> void:
	get_tree().paused = false
	load_scene(main_menu)

func _restart_level() -> void:
	get_tree().paused = false
	load_scene(levels[current_level_index]["level"])

func _level_cleared(stats, perfect_stats) -> void:
	var level = levels[current_level_index]
	level["completed"] = true
	level["kills"] = stats["kills"]
	level["damage taken"] = stats["damage taken"]
	level["time"] = stats["time"]
	load_scene(level_cleared_menu)
	#wait until next frame, then update current scene
	#(level cleared scene)
	#or update it before?

func _level_failed(stats) -> void:
	load_scene(level_failed_menu)

func _open_settings() -> void:
	load_scene(settings_menu)

func _open_level_select() -> void:
	load_scene(level_select_menu)
