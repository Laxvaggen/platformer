extends Node2D


func _process(delta: float) -> void:
	$Player.ap += 10


func _on_Back_pressed() -> void:
	SceneManager._return_to_menu()
