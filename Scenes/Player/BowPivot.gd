extends Position2D

var absolute_position: Vector2 = position

func set_own_position(position_x: float, position_y: float) -> void:
	absolute_position = Vector2(position_x, position_y)


func _process(delta: float) -> void:
	if abs(rotation) > PI/2:
		for child in get_children():
			if child is Sprite:
				child.position.y = -abs(child.position.y)
	else:
		for child in get_children():
			if child is Sprite:
				child.position.y = abs(child.position.y)
