class_name PlayerState
extends State

var player: Player
var animation_player: AnimationPlayer

func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)
	animation_player = player.get_node("AnimationPlayer")
	assert(animation_player is AnimationPlayer)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func get_direction_x() -> int:
	if Input.is_action_pressed("move_left"):
		return -1
	elif Input.is_action_pressed("move_right"):
		return 1
	return 0
