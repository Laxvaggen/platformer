extends State

onready var animation_player = $"../../AnimationPlayer"
onready var vision = $"../../Vision"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func _start_attack() -> void:
	$AttackCooldown.start()

func enter(_msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	_start_attack()
	
func exit() -> void:
	$AttackCooldown.stop()

func _on_AttackCooldown_timeout() -> void:
	if owner.position.x - owner.pursue_target.position.x < 0:
		owner.set_facing_x(1)
	else:
		owner.set_facing_x(-1)
	animation_player.play("Attack")
	animation_player.queue("Idle")
	if vision.get_overlapping_bodies().has(owner.pursue_target):
		if owner.get_distance_to_target(owner.pursue_target) < owner.dodge_range:
			state_machine.transition_to("Evade")
		else:
			_start_attack()
	else:
		state_machine.transition_to("Idle")
