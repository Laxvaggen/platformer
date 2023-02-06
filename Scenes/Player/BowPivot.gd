extends Position2D

var absolute_position: Vector2 = position

func set_own_position(position_x: float, position_y: float) -> void:
	absolute_position = Vector2(position_x, position_y)
