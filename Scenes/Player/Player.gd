class_name Player
extends KinematicBody2D

export (Resource) var stats

var velocity := Vector2.ZERO
var target_velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

var facing_x := 1
var direction_x := facing_x



onready var health: int = stats.max_hp

onready var state_locked_timer = $StateLockedTimer
onready var state_machine  = $PlayerStateMachine

func _ready():
	$Pivot.visible = false
	$PlayerStateMachine/Attack/AttackResetTimer.wait_time = 0.2/stats.atk_speed

func _process(delta):
	$PlayerStateMachine.state.update(delta)
	
func _physics_process(delta):
	$PlayerStateMachine.state.physics_update(delta)
	_move(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(damage:int, knockback:Vector2) -> void:
	health -= damage
	velocity = knockback

func reposition(x_offset:int=0, y_offset:int=0) -> void:
	global_position.x += x_offset * facing_x
	global_position.y += y_offset

func _move(delta) -> void:
	if velocity == target_velocity:
		return
	var x_velocity = move_toward(velocity.x, target_velocity.x, acceleration.x*delta)
	var y_velocity = move_toward(velocity.y, target_velocity.y, acceleration.y*delta)
	velocity = Vector2(x_velocity, y_velocity)
	
	
func set_target_velocity(velocity_x:int=velocity.x,  acceleration_x:int=0, velocity_y:int=velocity.y, acceleration_y:int=0) -> void:
	target_velocity = Vector2(velocity_x, velocity_y)
	acceleration = Vector2(acceleration_x, acceleration_y)

func set_velocity(velocity_x:int=velocity.x, velocity_y:int=velocity.y) -> void:
	target_velocity = Vector2(velocity_x, velocity_y)
	velocity = Vector2(velocity_x, velocity_y)

func lock_state_switching(time) -> void:
	state_locked_timer.stop()
	state_locked_timer.wait_time = time
	state_machine.state_locked = true
	state_locked_timer.start()

func set_facing_x(direction, force_look_forward=true) -> void:
	if !abs(direction) == 1:
		return
	if direction == facing_x:
		return

	flip_children(direction, self)
	
	facing_x = direction
	if force_look_forward:
		direction_x = direction

func flip_children(direction, target) -> void:
	if target == null:
		return
	var sprite_face_left:= false
	if direction == -1:
		sprite_face_left = true
	for child in target.get_children():
		if child.get("position"):
			child.position.x *= -1
		if child is Sprite:
			child.flip_h = sprite_face_left
		if child is RayCast2D:
			child.cast_to.x *= -1
		flip_children(direction, child)


func jump(strength_multiplier:=1) -> void:
	velocity.y = -stats.jump_strength*strength_multiplier
	global_position.y -= 2

func is_on_edge() -> bool:
	var val := false
	var wall_finder = $WallFinder
	var wall_finder_top = $WallFinderTop
	wall_finder.enabled = true
	wall_finder_top.enabled = true
	wall_finder.force_raycast_update()
	wall_finder_top.force_raycast_update()
	if wall_finder.is_colliding() and wall_finder.get_collider().is_in_group("Level"):
		if wall_finder_top.is_colliding() and wall_finder_top.get_collider().is_in_group("Level"):
			pass
		else:
			val = true
	wall_finder.enabled = false
	wall_finder_top.enabled = false
	return val

func is_on_wall() -> bool:
	var val := false
	var wall_finder = $WallFinder
	var wall_finder_top = $WallFinderTop
	wall_finder.enabled = true
	wall_finder_top.enabled = true
	wall_finder.force_raycast_update()
	wall_finder_top.force_raycast_update()
	if wall_finder.is_colliding() and wall_finder.get_collider().is_in_group("Level"):
		if wall_finder_top.is_colliding() and wall_finder_top.get_collider().is_in_group("Level"):
			val = true
		pass
	wall_finder.enabled = false
	wall_finder_top.enabled = false
	return val

func is_on_ground() -> bool:
	var val := false
	var ground_finder = $GroundFinder
	ground_finder.enabled = true
	ground_finder.force_raycast_update()
	if ground_finder.is_colliding() and ground_finder.get_collider().is_in_group("Level"):
		val = true
	ground_finder.enabled = false
	return val
	
func is_on_platform() -> bool:
	var val := false
	var ground_finder = $GroundFinder
	ground_finder.enabled = true
	ground_finder.force_raycast_update()
	if ground_finder.is_colliding() and ground_finder.get_collider().is_in_group("Oneway"):
		val = true
	ground_finder.enabled = false
	return val

func find_edge() -> void:
	var wall_finder_top = $WallFinderTop
	wall_finder_top.enabled = true
	for _i in range(12):
		global_position.y += 1
		wall_finder_top.force_raycast_update()
		if wall_finder_top.is_colliding() and wall_finder_top.get_collider().is_in_group("Level"):
			global_position.y -= 1
			break
	wall_finder_top.enabled = false

func close_to_ground() -> bool:
	var val := false
	var raycast = $CloseToGroundRaycast
	raycast.enabled = true
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Level"):
		val = true
	raycast.enabled = false
	return val

func close_to_wall() -> bool:
	var val := false
	var raycast = $CloseToWallRaycast
	raycast.enabled = true
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Level"):
		val = true
	raycast.enabled = false
	return val

func low_ceiling() -> bool:
	var val := false
	var raycast = $HeadInterferenceRaycast
	raycast.enabled = true
	raycast.force_raycast_update()
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Level"):
		val = true
	raycast.enabled = false
	return val

func set_collision_shape(height: String) -> void:
	assert(height == "low" or height == "high")
	if height == "low":
		$CollisionShapeCrouching.disabled = false
		$CollisionShapeStanding.disabled = true
	else:
		$CollisionShapeCrouching.disabled = true
		$CollisionShapeStanding.disabled = false

func _on_StateLockedTimer_timeout() -> void:
	state_machine.state_locked = false
