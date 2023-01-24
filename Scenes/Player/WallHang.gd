extends PlayerState

var did_jump = false

func enter(_msg:={}) -> void:
	animation_player.play("Catch Edge")
	player.velocity = Vector2.ZERO
	player.get_node("WallFinder").enabled = true
	player.get_node("WallFinderTop").enabled = true
	lock_state_switching(0.1)

func update(delta) -> void:
	pass

func physics_update(delta) -> void:
	apply_gravity(delta, 50)
	if Input.is_action_just_pressed("jump") and !did_jump:
		player.velocity.y = -player.stats.jump_strength
		player.velocity.x = -player.facing_x * 100
		player.velocity = player.move_and_slide(player.velocity)
		did_jump = true
		$"../../WallJumpResetTimer".start()
		
func exit() -> void:
	player.get_node("WallFinder").enabled = false
	player.get_node("WallFinderTop").enabled = false


func _on_WallJumpResetTimer_timeout():
	did_jump = false
