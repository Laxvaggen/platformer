extends PlayerState

#Available states for transition: Idle, Walk, Air, Crouch, Slide

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	player.set_target_velocity(player.stats.run_speed*get_direction_x(), player.stats.ground_acceleration)
	player.set_facing_x(get_direction_x())

func _get_next_state() -> void:
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		state_machine.transition_to("Idle", {unforce_animation=true})
		return
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", {do_jump=true})
		return
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Slide")
		return
	if Input.is_action_pressed("crouch") and player.is_on_platform():
		state_machine.transition_to("Air", {drop=true})
		return
	
	if !player.is_on_ground():
		state_machine.transition_to("Air")
	

func enter(_msg := {}) -> void:
	animation_player.play("Run")

func exit() -> void:
	animation_player.play("Run Stop")
