extends State

onready var animation_player = $"../../AnimationPlayer"
onready var vision = $"../../Vision"
onready var attack_range = $"../../AttackRange"

func update(_delta: float) -> void:
	if !vision.get_overlapping_bodies().has(owner.pursue_target):
		owner.pursue_target = null
		state_machine.transition_to("Idle")
	elif owner.get_distance_to_target(owner.pursue_target) < owner.dodge_range:
		state_machine.transition_to("Dodge")
	elif attack_range.get_overlapping_bodies().has(owner.pursue_target):
		state_machine.transition_to("Attack")

func physics_update(_delta: float) -> void:
	if owner.global_position.x > owner.pursue_target.global_position.x:
		owner.set_facing_x(-1)
	else:
		owner.set_facing_x(1)
	owner.velocity.x = owner.move_speed * owner.direction_x
	owner.apply_gravity(_delta)

func enter(_msg := {}) -> void:
	animation_player.play("Walk")

func exit() -> void:
	pass
