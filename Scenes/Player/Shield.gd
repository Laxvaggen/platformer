extends PlayerState

#bugged high jump when leaving 
#coyote?

func update(_delta: float) -> void:
	_get_next_state()
	player.set_facing_x(get_direction_x())

func physics_update(_delta: float) -> void:
	player.set_target_velocity(0, player.stats.ground_deceleration)
	
func receive_hit() -> void:
	animation_player.play("Shield Hit")
	player.lock_state_switching(0.3)

func _get_next_state() -> void:
	if !Input.is_action_pressed("shield"):
		animation_player.play("Shield Ready", -1, -1.25, true)
		yield(get_tree().create_timer(0.3/1.25), "timeout")
		state_machine.transition_to("Idle")
		return

func enter(_msg := {}) -> void:
	player.lock_state_switching(0.3/1.25)
	animation_player.play("Shield Ready", -1, 1.5)
	animation_player.animation_set_next("Shield Ready", "Shield Idle")

func exit() -> void:
	pass
