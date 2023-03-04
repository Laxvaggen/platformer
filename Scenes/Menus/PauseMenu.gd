extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		SceneManager._resume_game()
		queue_free()


func _on_Resume_pressed() -> void:
	SceneManager._resume_game()
	queue_free()


func _on_RestartLevel_pressed() -> void:
	SceneManager._restart_level()
	queue_free()


func _on_Exit_pressed() -> void:
	SceneManager._return_to_menu()
	queue_free()
