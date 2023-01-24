extends PlayerState

onready var ground_finder = $"../../GroundFinder"


func enter(_msg:={}) -> void:
	player.get_node("GroundFinder").enabled = true
	player.get_node("GroundFinder").force_raycast_update()
	if raycast_colliding_with_group("GroundFinder", "Oneway"):
		player.position.y += 2
		lock_state_switching(0.3)
	else:
		animation_player.play("Crouch")
	
func physics_update(delta) -> void:
	apply_gravity(delta)
	set_horizontal_vector(0, player.stats.ground_deceleration, delta)


func exit() -> void:
	player.get_node("GroundFinder").enabled = false
