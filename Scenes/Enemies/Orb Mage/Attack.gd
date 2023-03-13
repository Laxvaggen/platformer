extends State

onready var animation_player = $"../../AnimationPlayer"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func hide():
	#make mage hide until player is further away
	state_machine.transition_to("RangedAttack")

func enter(_msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	animation_player.play("Sweep Attack")
	
func exit() -> void:
	owner.disable_collision($"../../HitBox")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Sweep Attack":
		hide()
