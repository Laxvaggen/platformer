extends PlayerState

#Available states for transition: Idle, Run, Air (jump), Crouch, Roll, Attack

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	player.set_target_velocity(player.stats.walk_speed*get_direction_x(), player.stats.ground_acceleration)
	player.set_facing_x(get_direction_x())

func _get_next_state() -> void:
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		state_machine.transition_to("Idle")
		return
	if Input.is_action_just_pressed("sprint"):
		state_machine.transition_to("Run")
		return
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump=true})
		return
	if Input.is_action_pressed("crouch"):
		if player.is_on_platform():
			state_machine.transition_to("Air", {drop=true})
		else:
			state_machine.transition_to("Crouch")
		return
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Roll")
		return
	if Input.is_action_pressed("attack"):
		state_machine.transition_to("Attack")
		return
	if Input.is_action_pressed("ranged attack"):
		state_machine.transition_to("RangedAttack")
		return
	if Input.is_action_pressed("shield"):
		state_machine.transition_to("Shield")
		return
	
	
	if !player.is_on_ground():
		state_machine.transition_to("Air")
	

func enter(_msg := {}) -> void:
	animation_player.play("Walk")

func exit() -> void:
	pass
