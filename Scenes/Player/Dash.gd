extends PlayerState

#Available states for transition: Air, Idle


var dash_on_cooldown := false
onready var dash_timer = $DashTimer
onready var dash_cooldown = $DashCooldown
onready var tween = $"../../Tween"

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	pass

func _get_next_state() -> void:
	if player.is_on_edge():
		state_machine.transition_to("Edgehang")
		return
	if player.is_on_wall():
		state_machine.transition_to("Wallglide")
		return
	if player.is_on_ground():
		state_machine.transition_to("Roll")
		return

func enter(_msg := {}) -> void:
	if dash_on_cooldown:
		state_machine.transition_to("Air")
		return
	player.gain_ap(-3)
	animation_player.play("Dash")
	player.set_velocity(player.stats.dash_strength*player.facing_x)
	player.set_target_velocity(0, player.stats.air_acceleration, player.stats.max_fall_speed, player.stats.gravity_acceleration*0.75)

	dash_cooldown.start()
	dash_timer.start()
	dash_on_cooldown = true
	$"../../HurtBox".monitoring = false

func exit() -> void:
	dash_timer.stop()
	$"../../HurtBox".monitoring = true


func _on_DashTimer_timeout() -> void:
	if player.close_to_ground():
		state_machine.transition_to("Air")
	else:
		state_machine.transition_to("Air", {play_transition=true})


func _on_DashCooldown_timeout() -> void:
	dash_on_cooldown = false
