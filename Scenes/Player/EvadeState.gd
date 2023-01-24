extends PlayerState

onready var tween = $"../../Tween"

func enter(_msg={}) -> void:
	player.get_node("GroundFinder").enabled = true
	match _msg.get("last_state"):
		"Run":
			animation_player.play("Slide")
			tween.interpolate_property(player, "velocity",
			Vector2(200*player.facing_x, 0), Vector2(0, 0), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			lock_state_switching(0.5)
		_:
			animation_player.play("Roll")
			tween.interpolate_property(player, "velocity",
			Vector2(150*player.facing_x, 0), Vector2(0, 0), 1,
			Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
			tween.start()
			lock_state_switching(1)

func physics_update(delta) -> void:
	apply_gravity(delta)
	if !$"../../GroundFinder".is_colliding():
		player.position.x -= player.velocity.x * delta * 2
		player.velocity = Vector2.ZERO
		tween.stop(player)

func exit() -> void:
	player.velocity = Vector2(0, 0)
	tween.stop(player)
	player.get_node("GroundFinder").enabled = false
