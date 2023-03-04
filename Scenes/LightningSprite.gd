extends AnimatedSprite

export (NodePath) var timer

func _ready() -> void:
	randomize()

func _on_Timer_timeout() -> void:
	frame = 0
	play("default")
	get_node(timer).wait_time = rand_range(5, 10)
	get_node(timer).start()
