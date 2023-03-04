extends Control

var died := false
var kills: int
var damage_taken: int
var time: float

func _ready() -> void:
	if died:
		$VBoxContainer/Continue.disabled = true
	var label_container = $ColorRect/MarginContainer/VBoxContainer2/
	label_container.get_node("KillsLabel").text = "Kills------------------" + str(kills)
	label_container.get_node("DamageTakenLabel").text = "Damage Taken-" + str(damage_taken)
	label_container.get_node("TimeLabel").text = "Time-------------------" + str(round(time*10)/10)

func update_scene() -> void: 
	if died:
		$VBoxContainer/Continue.disabled = true
	var label_container = $ColorRect/MarginContainer/VBoxContainer2/
	label_container.get_node("KillsLabel").text = "Kills------------------" + str(kills)
	label_container.get_node("DamageTakenLabel").text = "Damage Taken-" + str(damage_taken)
	label_container.get_node("TimeLabel").text = "Time-------------------" + str(round(time*10)/10)

func _on_Continue_pressed() -> void:
	SceneManager._start_next_level()
	#queue_free()


func _on_RestartLevel_pressed() -> void:
	SceneManager._restart_level()
	#queue_free()


func _on_Exit_pressed() -> void:
	SceneManager._return_to_menu()
	#queue_free()
