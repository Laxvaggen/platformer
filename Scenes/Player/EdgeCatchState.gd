extends PlayerState


func enter(_msg={}) -> void:
	player.velocity = Vector2.ZERO
	animation_player.play("Climb from Ledge")
	lock_state_switching(0.4)
	go_to_wall()

func switch_to_climb() -> void:
	animation_player.play("Climb from Ledge")

func go_to_wall() -> void:
	player.get_node("WallFinderTop").enabled = true
	for _i in range(10):
		player.get_node("WallFinderTop").force_raycast_update()
		if $"../../WallFinderTop".is_colliding():
			break
		player.position.y += 1
	player.get_node("WallFinderTop").enabled = false

func reposition_for_climb() -> void:
	player.position += Vector2(5*player.facing_x, -20)
