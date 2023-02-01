extends PlayerState

#Available states for transition: Wallglide, Idle, Air (jump)

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	player.set_facing_x(get_direction_x())

func _get_next_state() -> void:
	if !player.is_on_edge():
		state_machine.transition_to("Air")
		return
	if Input.is_action_pressed("jump"):
		player.set_velocity(player.stats.jump_strength*0.33 * player.facing_x * -1)
		state_machine.transition_to("Air", {do_jump=true})
		return
	
	if (Input.is_action_pressed("move_left") and player.facing_x == -1) or (Input.is_action_pressed("move_right") and player.facing_x == 1):
		animation_player.play("Climb from Ledge")
		state_machine.transition_to("Idle", {unforce_animation=true})
		player.lock_state_switching(0.5)
		return
	if Input.is_action_pressed("crouch"):
		player.global_position.y += 2
		state_machine.transition_to("Wallglide")
		return


func enter(_msg := {}) -> void:
	player.set_velocity(0, 0)
	player.find_edge()
	animation_player.play("Catch Edge")
	

func exit() -> void:
	pass