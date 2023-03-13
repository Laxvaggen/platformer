extends State

#Play first attack, then wait for a second, then if player is still
#in range: play second attack
#if player is too close, then dodge
#if player is not in attack range, then switch to hunt
var last_attack := 0

onready var animation_player = $"../../AnimationPlayer"
onready var attack_range = $"../../AttackRange"

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func pause_attacks(time:float) -> void:
	animation_player.stop(false)
	$AttackCooldown.wait_time = time
	$AttackCooldown.start()

func pursue_target_in_range() -> bool:
	if attack_range.get_overlapping_bodies().has(owner.pursue_target):
		return true
	return false

func enter(_msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	animation_player.play("Attack")
	
func exit() -> void:
	owner.disable_collision($"../../HitBox")
	$"../../VFXSprite".visible = false
	$AttackCooldown.stop()

func _on_AttackCooldown_timeout() -> void:
	if pursue_target_in_range():
		animation_player.play("Attack")
	else:
		state_machine.transition_to("Hunt")
