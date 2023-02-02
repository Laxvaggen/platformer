extends PlayerState

#Available states for transition: Idle, Run, Air (jump), Crouch, Roll, Attack

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	player.set_target_velocity(0, 0, player.stats.max_fall_speed, player.stats.gravity_acceleration)

func _get_next_state() -> void:
	if player.is_on_ground():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")

func enter(_msg := {}) -> void:
	player.lock_state_switching(0.2)
	animation_player.play("Crouch")

func exit() -> void:
	pass
