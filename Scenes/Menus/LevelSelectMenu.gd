extends Control

var selectable_levels: Array

var level_index := 0
var max_index: int

func _ready() -> void:
	for level in SceneManager.levels:
		if SceneManager.completed_levels_data.has(level["name"]):
			selectable_levels.append(level)
	max_index = selectable_levels.size() - 1
	_load_level_data()

func _physics_process(delta: float) -> void:
	var mouse_pos = (get_global_mouse_position() - get_viewport().size/2)/(get_viewport().size/2)
	$ParallaxBackground.scroll_offset = mouse_pos * 10

func _load_level_data() -> void:
	var level = selectable_levels[level_index]
	var stats = SceneManager.completed_levels_data[level["name"]]
	var label_container = $ColorRect/MarginContainer/VBoxContainer2/
	label_container.get_node("KillsLabel").text = "Kills------------------" + str(stats["kills"])
	label_container.get_node("DamageTakenLabel").text = "Damage Taken-" + str(stats["damage taken"])
	label_container.get_node("TimeLabel").text = "Time-------------------" + str(stats["time"])
	$LevelName.text = level["name"]

func _on_Back_pressed() -> void:
	SceneManager._return_to_menu()


func _on_LevelPrevious_pressed() -> void:
	level_index -= 1
	if level_index < 0:
		level_index = max_index
	_load_level_data()


func _on_LevelNext_pressed() -> void:
	level_index += 1
	if level_index > max_index:
		level_index = 0
	_load_level_data()


func _on_EnterLevel_pressed() -> void:
	SceneManager._enter_level(SceneManager.levels.find(selectable_levels[level_index]))
