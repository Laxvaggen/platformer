extends State

onready var animation_player = $"../../AnimationPlayer"
onready var vision = $"../../Vision"

func update(_delta: float) -> void:
	if owner.pursue_target is KinematicBody2D:
		if owner.can_see_target(owner.pursue_target):
			state_machine.transition_to("Hunt")

func physics_update(_delta: float) -> void:
	owner.apply_gravity(_delta)

func enter(_msg := {}) -> void:
	animation_player.play("Idle")
	owner.velocity = Vector2.ZERO

func exit() -> void:
	pass


func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		owner.pursue_target = body
