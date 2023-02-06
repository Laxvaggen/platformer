extends PlayerState

#Can idle, walk, run, crouch, air



onready var pivot = $"../../BowPivot"


func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	set_rotation(player.get_angle_to(player.get_global_mouse_position()))

func set_rotation(angle) -> void:
	if abs(angle) > PI/2:
		player.set_facing_x(-1)
		pivot.get_node("BowSprite").flip_v = true
		pivot.position.x = pivot.absolute_position.x * -1
		
		
	else:
		player.set_facing_x(1)
		pivot.get_node("BowSprite").flip_v = false
		pivot.position.x = pivot.absolute_position.x * 1
	pivot.position.y = pivot.absolute_position.y
	pivot.rotation = angle

func _get_next_state() -> void:
	if !Input.is_action_pressed("ranged attack"):
		pivot.get_node("AnimationPlayer").play("Bow Fire")
		yield(pivot.get_node("AnimationPlayer"), "animation_finished")
		if player.is_on_ground():
			state_machine.transition_to("Idle")
			return
		else:
			state_machine.transition_to("Air")



func enter(_msg := {}) -> void:
	pivot.visible = true
	pivot.get_node("AnimationPlayer").play("Bow Ready")

func exit() -> void:
	pivot.visible = false
