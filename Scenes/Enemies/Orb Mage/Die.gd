extends State

#disable all collision, play death animation, stop as much code
#from executing as possible for speeds sake

onready var animation_player = $"../../AnimationPlayer"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	animation_player.play("Die")
	owner.velocity = Vector2.ZERO
	owner.disable_collision(owner)
	owner.emit_signal("died")
	for i in range(10):
		owner.summon_hp_orb()

func exit() -> void:
	pass
