extends PlayerState

func enter(_msg := {}) -> void:
	
	if _msg.get("last_state") == "Run":
		animation_player.play("Run Stop")
		animation_player.queue("Idle")
	elif _msg.get("last_state") == "EdgeCatch":
		animation_player.queue("Idle")
	elif _msg.get("last_state") == "Attack":
		pass
	else:
		animation_player.play("Idle")
	player.velocity.y = 0

func update(delta) -> void:
	set_player_x_direction()

func physics_update(delta) -> void:
	
	apply_gravity(delta)
	set_horizontal_vector(0, player.stats.ground_deceleration, delta)

"""
func exit() -> void:
	$"../../AttackResetTimer".stop()
"""

func _on_AttackResetTimer_timeout() -> void:
	if animation_player.is_playing():
		return
	animation_player.play("Idle")
