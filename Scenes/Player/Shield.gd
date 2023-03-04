extends PlayerState

#bugged high jump when leaving 
#coyote?

onready var pivot = $"../../Pivot"

func update(_delta: float) -> void:
	_get_next_state()
	player.set_facing_x(get_direction_x())

func physics_update(_delta: float) -> void:
	set_rotation(player.get_angle_to(player.get_global_mouse_position()))
	player.set_target_velocity(0, player.stats.ground_deceleration)
	
func set_rotation(angle) -> void:
	if abs(angle) > PI/2:
		player.set_facing_x(-1)
		pivot.get_node("ShieldSprite").flip_v = true
		pivot.position.x = pivot.absolute_position.x * -1
	else:
		player.set_facing_x(1)
		pivot.get_node("ShieldSprite").flip_v = false
		pivot.position.x = pivot.absolute_position.x * 1
	pivot.position.y = pivot.absolute_position.y
	pivot.rotation = angle

func receive_hit() -> void:
	#animation_player.play("Shield Hit")
	player.lock_state_switching(0.2)

func _get_next_state() -> void:
	if !Input.is_action_pressed("shield"):
		state_machine.transition_to("Idle", {unforce_animation=true})
		return

func enter(_msg := {}) -> void:
	player.lock_state_switching(0.3/1.25)
	#animation_player.play("Shield Ready", -1, 2)
	#animation_player.animation_set_next("Shield Ready", "Shield Idle")
	pivot.get_node("ShieldSprite").visible = true

func exit() -> void:
	#animation_player.play("Shield Ready", -1, -2, true)
	pivot.get_node("ShieldSprite").visible = false
