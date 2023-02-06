extends PlayerState

#Available states for transition: Air, Idle

var last_attack: int

onready var attack_reset_timer = $AttackResetTimer
onready var tween = $"../../Tween"


func update(_delta: float) -> void:
	
	if Input.is_action_pressed("attack") and !state_machine.state_locked:
		_play_next_attack()
	else:
		_get_next_state()

func physics_update(_delta: float) -> void:
	pass

func _play_next_attack(stab:bool=false) -> void:
	if stab:
		animation_player.play("Attack 3",-1, player.stats.atk_speed)
		player.lock_state_switching(0.8/player.stats.atk_speed)
		attack_reset_timer.start(1.2/player.stats.atk_speed)
		return
	if last_attack == 1:
		animation_player.play("Attack 2",-1, player.stats.atk_speed)
		player.lock_state_switching(0.6/player.stats.atk_speed)
		attack_reset_timer.start(1/player.stats.atk_speed)
	else:
		animation_player.play("Attack 1",-1, player.stats.atk_speed)
		player.lock_state_switching(1/player.stats.atk_speed)
		attack_reset_timer.start(1.4/player.stats.atk_speed)
	last_attack += 1
	if last_attack > 2:
		last_attack = 1



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
		state_machine.transition_to("Crouch")
		return
	
	if !player.is_on_ground():
		player.unlock_state_switching()
		state_machine.transition_to("Air")
		return


func enter(_msg := {}) -> void:
	if _msg.has("stab"):
		_play_next_attack(true)
		player.set_target_velocity(0, player.stats.ground_deceleration*0.5)
	else:
		_play_next_attack()
		player.set_velocity(0, 0)
	

func exit() -> void:
	attack_reset_timer.stop()
	last_attack = 0


func _on_AttackResetTimer_timeout() -> void:
	state_machine.transition_to("Idle")
