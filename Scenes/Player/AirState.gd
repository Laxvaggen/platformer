extends PlayerState

var did_jump: bool
var last_vert_speed: float

onready var coyote_timer = $"../../CoyoteTimer"

func enter(_msg:={}) -> void:
	if _msg.has("do_jump"):
		player.velocity.y = -player.stats.jump_strength
		player.velocity = player.move_and_slide(player.velocity)
		did_jump = true
	else:
		did_jump = false
		coyote_timer.start()
	player.get_node("WallFinder").enabled = true
	player.get_node("WallFinderTop").enabled = true

func update(_delta) -> void:
	set_player_x_direction()
	if player.velocity.y < 0:
		animation_player.play("Jump")
		if player.is_on_ceiling():
			player.velocity.y = 0
	else:
		if last_vert_speed <= 0: 
			if!$"../../Bow".active:
				animation_player.play("Jump to Fall Transition")
			else:
				animation_player.play("Fall")
		else:
			animation_player.queue("Fall")
	last_vert_speed = player.velocity.y

func physics_update(delta) -> void:
	if coyote_timer.time_left > 0 and Input.is_action_just_pressed("jump") and !did_jump:
		player.velocity.y = -player.stats.jump_strength
		player.velocity = player.move_and_slide(player.velocity)
		did_jump = true
	apply_gravity(delta)
	set_horizontal_vector(player.stats.air_speed*player.direction_x, player.stats.air_acceleration, delta)

func exit() -> void:
	player.get_node("WallFinder").enabled = false
	player.get_node("WallFinderTop").enabled = false
	pass
	
