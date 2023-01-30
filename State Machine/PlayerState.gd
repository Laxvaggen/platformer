class_name PlayerState
extends State

var player: Player
var target_velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

#lock state switching
#set_target_velocity with default parameters as current player velocity
#set_velocity moves player velocity towards target
#

func _set_velocity() -> void:
	if player.velocity == target_velocity:
		return
	
func set_target_velocity(velocity_x:int, velocity_y: int, acceleration_x:int, acceleration_y: int) -> void:
	pass
