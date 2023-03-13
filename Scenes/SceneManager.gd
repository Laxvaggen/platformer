extends Node2D

var level_1 = {"filepath":"res://Scenes/Levels/Level1.tscn",
				"name":"level1"}
var level_2 = {"filepath":"res://Scenes/Levels/Level2.tscn",
				"name":"level2"}
var levels: Array = [level_1, level_2]
var completed_levels_data: Dictionary
var current_level_index: int



var main_menu = "res://Scenes/Menus/MainMenu.tscn"

var level_cleared_menu = "res://Scenes/Menus/LevelClearedMenu.tscn"
var level_failed_menu = "res://Scenes/Menus/LevelFailedMenu.tscn"
var controls_menu = "res://Scenes/Menus/ControlsMenu.tscn"
var level_select_menu = "res://Scenes/Menus/LevelSelectMenu.tscn"
var game_complete_menu = "res://Scenes/Menus/GameCompleteMenu.tscn"
var background = "res://Scenes/ParallaxBackground.tscn"

var pause_menu = preload("res://Scenes/Menus/PauseMenu.tscn")

func _ready() -> void:
	import_savedata()
	current_level_index = completed_levels_data.size() -1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and get_tree().current_scene.is_in_group("Levels"):
		var pause_menu_instance = pause_menu.instance()
		get_tree().get_root().add_child(pause_menu_instance)


func load_scene(scene, in_game=false):
	var transition_scene = $Transition
	transition_scene.visible = true
	transition_scene.animation_player.play("fade_in")
	yield(transition_scene.animation_player, "animation_finished")
	get_tree().change_scene(scene)
	if in_game:
		$HUD.visible = true
	else:
		$HUD.visible = false
	transition_scene.animation_player.play_backwards("fade_in")
	yield(transition_scene.animation_player, "animation_finished")
	transition_scene.visible = false

func _start_next_level() -> void:
	if current_level_index >= levels.size()-1:
		if all_levels_completed():
			load_scene(game_complete_menu)
			return
		_return_to_menu()
		return
	current_level_index += 1
	load_scene(levels[current_level_index]["filepath"], true)

func _start_new_game() -> void:
	current_level_index = 0
	load_scene(levels[0]["filepath"], true)
	completed_levels_data = {}
	export_savedata()

func _enter_level(index) -> void:
	load_scene(levels[index]["filepath"], true)

func _resume_game() -> void:
	get_tree().paused = false

func _return_to_menu() -> void:
	get_tree().paused = false
	load_scene(main_menu)

func _restart_level() -> void:
	get_tree().paused = false
	load_scene(levels[current_level_index]["filepath"], true)

func _level_cleared(stats) -> void:
	var level = levels[current_level_index]
	if !completed_levels_data.has(level["name"]):
		completed_levels_data[level["name"]] = stats
	elif completed_levels_data[level["name"]]["time"] > stats["time"]:
		completed_levels_data[level["name"]] = stats
	load_scene(level_cleared_menu)
	export_savedata()
	yield($Transition.animation_player, "animation_finished")
	yield(get_tree(), "idle_frame")
	get_node("/root/LevelClearedMenu").update_data(stats)

func _level_failed(stats) -> void:
	load_scene(level_failed_menu)

func _open_controls() -> void:
	load_scene(controls_menu)

func _open_level_select() -> void:
	load_scene(level_select_menu)


func export_savedata() -> void:
	#export completed_levels_data dictionary to json
	var save_data = completed_levels_data
	var file = File.new()
	file.open("user://save_data.json", File.WRITE)
	file.store_line(to_json(save_data))
	file.close()

func import_savedata() -> void:
	var file = File.new()
	if not file.file_exists("user://save_data.json"):
		export_savedata()
		return
	file.open("user://save_data.json", File.READ)
	var save_data = parse_json(file.get_as_text())
	completed_levels_data = save_data


func reparent(node, old_parent, new_parent) -> void:
	old_parent.remove_child(node)
	new_parent.add_child(node)

func all_levels_completed() -> bool:
	if completed_levels_data.has(levels[-1]["name"]):
		return true
	else:
		return false
