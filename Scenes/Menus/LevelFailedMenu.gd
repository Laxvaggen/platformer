extends Control


func _ready() -> void:
	pass


func _on_RestartLevel_pressed() -> void:
	SceneManager._restart_level()
	#queue_free()


func _on_Exit_pressed() -> void:
	SceneManager._return_to_menu()
	#queue_free()
