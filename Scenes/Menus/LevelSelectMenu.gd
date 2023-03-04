extends Control


func _physics_process(delta: float) -> void:
	var mouse_pos = (get_global_mouse_position() - get_viewport().size/2)/(get_viewport().size/2)
	$ParallaxBackground.scroll_offset = mouse_pos * 10


func _on_Back_pressed() -> void:
	SceneManager._return_to_menu()
