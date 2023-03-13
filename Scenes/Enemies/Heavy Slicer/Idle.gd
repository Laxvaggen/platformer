extends State

onready var animation_player = $"../../AnimationPlayer"
onready var vision = $"../../Vision"

func update(_delta: float) -> void:
	if owner.pursue_target is KinematicBody2D:
		if owner.can_see_target(owner.pursue_target):
			state_machine.transition_to("Hunt")

func physics_update(_delta: float) -> void:
	owner.apply_gravity(_delta)
	if abs(owner.spawn_coordinates.x-owner.global_position.x) < 25:
		animation_player.play("Idle")
		owner.velocity = Vector2.ZERO
	elif owner.global_position.x-owner.spawn_coordinates.x > 0:
		animation_player.play("Walk")
		owner.set_facing_x(-1)
		owner.velocity.x = owner.move_speed * owner.direction_x
	else:
		animation_player.play("Walk")
		owner.set_facing_x(1)
		owner.velocity.x = owner.move_speed * owner.direction_x

func enter(_msg := {}) -> void:
	animation_player.play("Idle")
	owner.velocity = Vector2.ZERO

func exit() -> void:
	pass


func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		owner.pursue_target = body
