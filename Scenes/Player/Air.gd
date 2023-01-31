extends PlayerState

#Available states for transition: Idle, Dash, EdgeCatch, WallHang, Attack(?)

func update(_delta: float) -> void:
	_get_next_state()
	if animation_player.current_animation == "Jump" and player.velocity.y >= 0:
		animation_player.play("Jump to Fall Transition")
		animation_player.animation_set_next("Jump to Fall Transition", "Fall")

func physics_update(_delta: float) -> void:
	player.set_target_velocity(player.stats.air_speed*get_direction_x(), player.stats.air_acceleration, 
								player.stats.max_fall_speed, player.stats.gravity_acceleration)
	player.set_facing_x(get_direction_x())

func _get_next_state() -> void:
	
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Dash")
		return
	
	if player.is_on_ground():
		state_machine.transition_to("Idle")
		return
	if player.is_on_edge() and player.velocity.y >= 0:
		state_machine.transition_to("Edgehang")
		return
	if player.is_on_wall() and player.velocity.y >= 0:
		state_machine.transition_to("Wallglide")
		return

func enter(_msg := {}) -> void:
	if _msg.has("do_jump"):
		animation_player.play("Jump")
		player.jump()
	else:
		animation_player.play("Fall")


func exit() -> void:
	pass
