extends StateMachine

var player: Player

onready var state_locked_timer = $"../StateLockedTimer"
onready var wall_finder = $"../WallFinder"
onready var wall_finder_top = $"../WallFinderTop"
onready var coyote_timer = $"../CoyoteTimer"
onready var bow = $"../Bow"

func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)
	state.enter()
	

func update(delta: float) -> void:
	state.update(delta)
	_update_bow(state.name)
	if state_locked_timer.time_left <= 0:
		var next_state = get_next_state(state.name)
		if state.name != next_state.state:
			transition_to(next_state.state, next_state.msg)
	
func physics_update(delta: float) -> void:
	state.physics_update(delta)

func raycast_colliding_with_group(raycast_id:String, tilemap_group:String) -> bool:
	var tilemaps = get_tree().get_nodes_in_group(tilemap_group)
	var ray = player.get_node(raycast_id)
	assert(ray is RayCast2D)
	for tilemap in tilemaps:
		if ray.is_colliding() and ray.get_collider() == tilemap:
			return true
	return false

func _update_bow(current_state_id:String) -> void:
	bow.update(current_state_id)
	if bow.accepted_states.has(current_state_id):
		if Input.is_action_just_pressed("fire arrow 1") and player.arrowslots[0].count > 0:
			bow.enter(player.arrowslots[0].arrow, 0)
		elif Input.is_action_just_pressed("fire arrow 2") and player.arrowslots[1].count > 0:
			bow.enter(player.arrowslots[1].arrow, 1)
		elif Input.is_action_just_released("fire arrow 1") or Input.is_action_just_released("fire arrow 2"):
			bow.fire()
	else:
		bow.exit()

func get_next_state(current_state:String) -> Dictionary:
	if state_locked_timer.time_left > 0:
		return {"state":current_state, "msg":{"last_state":current_state}}
	
	var next_state: String
	var msg := {"last_state":current_state}
	if !player.is_on_floor():
		if player.velocity.y >= 0 and wall_finder.is_colliding():
			if !wall_finder_top.is_colliding():
				next_state = "EdgeCatch"
			else:
				next_state = "WallHang"
		else:
			next_state = "Air"
	elif Input.is_action_just_pressed("jump"):
		next_state = "Air"
		msg["do_jump"] = true
	elif Input.is_action_pressed("crouch"):
		next_state = "Crouch"
	elif Input.is_action_just_pressed("evade"):
		next_state = "Evade"
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		if (Input.is_action_pressed("sprint") or state.name == "Run") and player.facing_x == player.direction_x:
			next_state = "Run"
			
		else:
			next_state = "Walk"
	else: 
		next_state = "Idle"
	return {"state":next_state, "msg":msg}
