extends State

#jump backwards, then switch to hunt

onready var animation_player = $"../../AnimationPlayer"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	owner.apply_gravity(_delta)

func enter(_msg := {}) -> void:
	owner.velocity = Vector2(75*owner.direction_x*-1, -30)
	$Timer.start()

func exit() -> void:
	pass


func _on_Timer_timeout() -> void:
	state_machine.transition_to("Hunt")
