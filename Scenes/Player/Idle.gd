extends PlayerState

#Available states for transition: Walk, Run, Air (jump), Crouch, Roll, Attack

func update(_delta: float) -> void:
	_get_next_state()
	player.gain_ap(-1*_delta)

func physics_update(_delta: float) -> void:
	player.set_target_velocity(0, player.stats.ground_deceleration)

func _get_next_state() -> void:
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		player.set_facing_x(get_direction_x(), true)
		if Input.is_action_pressed("sprint"):
			state_machine.transition_to("Run")
			return
		else:
			state_machine.transition_to("Walk")
			return
	
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump=true})
		return
	
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Roll")
		return
	
	if Input.is_action_pressed("crouch"):
		if player.is_on_platform():
			state_machine.transition_to("Air", {drop=true})
		else:
			state_machine.transition_to("Crouch")
		return
	
	if Input.is_action_pressed("attack"):
		state_machine.transition_to("Attack")
		return
	
	if Input.is_action_pressed("shield"):
		state_machine.transition_to("Shield")
		return
	
	if Input.is_action_pressed("ranged attack"):
		state_machine.transition_to("RangedAttack")
		return
	
	if !player.is_on_floor():
		state_machine.transition_to("Air")
		return


func enter(_msg := {}) -> void:
	if !_msg.has("unforce_animation"):
		animation_player.play("Idle")
	else:
		animation_player.queue("Idle")

func exit() -> void:
	pass
