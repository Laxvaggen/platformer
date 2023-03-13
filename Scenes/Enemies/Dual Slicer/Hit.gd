extends State

#play hit animation, and apply knockback
#then switch to hunt

onready var animation_player = $"../../AnimationPlayer"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	owner.apply_gravity(_delta)

func enter(_msg := {}) -> void:
	animation_player.play("Hit")
	$Timer.start()
	for i in range(5):
		owner.summon_ap_orb()

func exit() -> void:
	pass


func _on_Timer_timeout() -> void:
	if owner.health <= 0:
		state_machine.transition_to("Die")
	else:
		state_machine.transition_to("Hunt")
