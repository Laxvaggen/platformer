extends State

onready var animation_player = $"../../AnimationPlayer"
onready var vision = $"../../Vision"

func update(_delta: float) -> void:
	if owner.pursue_target is KinematicBody2D:
		state_machine.transition_to("RangedAttack")

func physics_update(_delta: float) -> void:
	pass
func enter(_msg := {}) -> void:
	animation_player.play("Idle")
	owner.velocity = Vector2.ZERO

func exit() -> void:
	pass


func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		owner.pursue_target = body
