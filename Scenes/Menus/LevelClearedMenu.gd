extends Control

func _ready() -> void:
	pass

func update_data(stats:Dictionary) -> void:
	var label_container = $ColorRect/MarginContainer/VBoxContainer2/
	label_container.get_node("KillsLabel").text = "Kills------------------" + str(stats["kills"])
	label_container.get_node("DamageTakenLabel").text = "Damage Taken-" + str(stats["damage taken"])
	label_container.get_node("TimeLabel").text = "Time-------------------" + str(stats["time"])

func _on_Continue_pressed() -> void:
	SceneManager._start_next_level()
	#queue_free()


func _on_RestartLevel_pressed() -> void:
	SceneManager._restart_level()
	#queue_free()


func _on_Exit_pressed() -> void:
	SceneManager._return_to_menu()
	#queue_free()
