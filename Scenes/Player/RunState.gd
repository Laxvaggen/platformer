extends PlayerState

func enter(_msg:={}) -> void:
	animation_player.play("Run")

func update(delta) -> void:
	set_player_x_direction()

func physics_update(delta) -> void:
	apply_gravity(delta)
	set_horizontal_vector(player.stats.run_speed*player.direction_x, player.stats.ground_acceleration, delta)
