class_name PlayerState
extends State

var player: Player
var x_direction := 1

onready var animation_player:AnimationPlayer = owner.get_node("AnimationPlayer")
onready var state_locked_timer:Timer = owner.get_node("StateLockedTimer")

func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)

func set_horizontal_vector(magnitude:float, acceleration, delta) -> void:
	player.velocity.x = move_toward(player.velocity.x, magnitude, acceleration*delta)

func apply_gravity(delta, acceleration=player.stats.gravity_acceleration, magnitude=player.stats.max_fall_speed) -> void:
	player.velocity.y = move_toward(player.velocity.y, magnitude, acceleration*delta)

func set_player_x_direction() -> void:
	if Input.is_action_pressed("move_left"):
		player.facing_x = -1
		player.direction_x = -1
	elif Input.is_action_pressed("move_right"):
		player.facing_x = 1
		player.direction_x = 1
	else:
		player.direction_x = 0

func lock_state_switching(time=null) -> void:
	if time == null:
		state_locked_timer.wait_time = 9999
	else:
		state_locked_timer.wait_time = time
	state_locked_timer.start()

func unlock_state_switching(time=null) -> void:
	if time == null:
		state_locked_timer.stop()
	else:
		state_locked_timer.wait_time = time
		state_locked_timer.start()

func raycast_colliding_with_group(raycast_id:String, tilemap_group:String) -> bool:
	var tilemaps = get_tree().get_nodes_in_group(tilemap_group)
	var ray = player.get_node(raycast_id)
	assert(ray is RayCast2D)
	for tilemap in tilemaps:
		if ray.is_colliding() and ray.get_collider() == tilemap:
			return true
	return false
