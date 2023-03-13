extends PlayerState

#Available states for transition: Air (jump)

var can_jump := true

func update(_delta: float) -> void:
	player.gain_ap(-1*_delta)
	player.set_target_velocity(0, player.stats.air_acceleration, 
								player.stats.wall_fall_speed, player.stats.wall_acceleration)
	_get_next_state()

func physics_update(_delta: float) -> void:
	player.set_facing_x(get_direction_x())
	
func _get_next_state() -> void:
	if Input.is_action_pressed("jump") and can_jump:
		player.set_velocity(player.stats.jump_strength*0.33 * player.facing_x * -1)
		state_machine.transition_to("Air", {do_jump=true})
		$WallJumpResetTimer.start()
		can_jump = false
	if player.is_on_ground():
		state_machine.transition_to("Idle")
		return
	if !player.is_on_wall():
		state_machine.transition_to("Air")
		return

func enter(_msg := {}) -> void:
	animation_player.play("Catch Edge")

func exit() -> void:
	pass


func _on_WallJumpResetTimer_timeout() -> void:
	can_jump = true
