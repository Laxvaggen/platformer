extends PlayerState

#Available states for transition: Idle
onready var tween = $"../../Tween"

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	if !player.is_on_ground():
		player.position.x -= player.velocity.x * _delta * 2
		player.set_velocity(0, 0)
		tween.stop(player)

func _get_next_state() -> void:
	if player.low_ceiling():
		state_machine.transition_to("Crouch")
		return
	state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	animation_player.play("Roll", -1, 1.5)
	tween.interpolate_property(player, "velocity",
	Vector2(150*player.facing_x, 0), Vector2(0, 0), 1,
	Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()
	player.lock_state_switching(0.6)
	player.set_collision_shape("low")
	$"../../HurtBox".monitoring = false

func exit() -> void:
	player.set_velocity(0, 0)
	tween.stop(player)
	player.set_collision_shape("high")
	$"../../HurtBox".monitoring = true
