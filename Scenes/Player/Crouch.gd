extends PlayerState

#Available states for transition: Idle

func update(_delta: float) -> void:
	_get_next_state()
	player.set_facing_x(get_direction_x())

func physics_update(_delta: float) -> void:
	player.set_target_velocity(0, player.stats.ground_deceleration)
	

func _get_next_state() -> void:
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Roll")
		return
	if !Input.is_action_pressed("crouch") and !player.low_ceiling():
			state_machine.transition_to("Idle")
			return
	if Input.is_action_pressed("ranged attack"):
		state_machine.transition_to("RangedAttack")
		return

func enter(_msg := {}) -> void:
	animation_player.play("Crouch")
	player.set_collision_shape("low")

func exit() -> void:
	player.set_collision_shape("high")
