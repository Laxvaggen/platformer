extends PlayerState

onready var attack_reset_timer = $"../../AttackResetTimer"

func enter(msg={}) -> void:
	player.velocity = Vector2.ZERO
	animation_player.playback_speed = 1.5
	attack_reset_timer.start()
	animation_player.play("Attack 1")
	lock_state_switching(0.6)

func exit() -> void:
	animation_player.playback_speed = 1
