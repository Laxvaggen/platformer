extends PlayerState

var last_attack := 0

onready var hitbox = $"../../Hitbox"

func enter(_msg := {}) -> void:
	$"../../AttackResetTimer".stop()
	animation_player.playback_speed = player.stats.atk_speed
	if last_attack == 1:
		animation_player.play("Attack 2")
		lock_state_switching(0.6/player.stats.atk_speed)
		last_attack = 2
	elif last_attack == 2:
		animation_player.play("Attack 3")
		lock_state_switching(1/player.stats.atk_speed)
		last_attack = 3
	elif last_attack == 3:
		animation_player.play("Attack 1")
		lock_state_switching(1/player.stats.atk_speed)
		last_attack = 1
	else:
		animation_player.play("Attack Ready")
		animation_player.queue("Attack 1")
		lock_state_switching(1.4/player.stats.atk_speed)
		last_attack = 1
	
	player.velocity = Vector2.ZERO
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass



func exit() -> void:
	animation_player.playback_speed = 1
	$"../../AttackResetTimer".start()


func _on_AttackResetTimer_timeout() -> void:
	last_attack = 0
