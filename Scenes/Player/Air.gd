extends PlayerState

#Available states for transition: Idle, Dash, EdgeCatch, WallHang, Attack(?)

onready var coyote_timer = $"../../CoyoteTimer"
var coyote := false

func update(_delta: float) -> void:
	player.gain_ap(-1*_delta)
	_get_next_state()
	if animation_player.current_animation == "Jump" and player.velocity.y >= 0:
		if player.close_to_wall():
			animation_player.play("Fall")
		else:
			animation_player.play("Jump to Fall Transition", -1, 1.5)
			animation_player.animation_set_next("Jump to Fall Transition", "Fall")

func physics_update(_delta: float) -> void:
	player.set_target_velocity(player.stats.air_speed*get_direction_x(), player.stats.air_acceleration, 
								player.stats.max_fall_speed, player.stats.gravity_acceleration)
	player.set_facing_x(get_direction_x())

func _get_next_state() -> void:
	
	if Input.is_action_pressed("evade"):
		state_machine.transition_to("Dash")
		return
	if Input.is_action_just_pressed("jump") and coyote:
		animation_player.play("Jump")
		player.jump()
		coyote_timer.stop()
		coyote = false
	if player.is_on_ground():
		state_machine.transition_to("Idle")
		return
	if player.is_on_edge() and player.velocity.y >= 0:
		state_machine.transition_to("Edgehang")
		return
	if player.is_on_wall() and player.velocity.y >= 0:
		state_machine.transition_to("Wallglide")
		return
	if Input.is_action_pressed("ranged attack"):
		state_machine.transition_to("RangedAttack")
		return

func enter(_msg := {}) -> void:
	if _msg.has("do_jump"):
		animation_player.play("Jump")
		player.jump()
	elif _msg.has("drop"):
		player.global_position.y += 2
		animation_player.play("Jump to Fall Transition", -1, 1.5)
		animation_player.animation_set_next("Jump to Fall Transition", "Fall")
		player.lock_state_switching(0.2)
	elif _msg.has("play_transition"):
		animation_player.play("Jump to Fall Transition", -1, 1.5)
		animation_player.animation_set_next("Jump to Fall Transition", "Fall")
	else:
		animation_player.play("Fall")
		coyote_timer.start()
		coyote = true
	


func exit() -> void:
	coyote_timer.stop()
	coyote = false


func _on_CoyoteTimer_timeout() -> void:
	coyote = false
