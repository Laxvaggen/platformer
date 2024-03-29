class_name Player
extends KinematicBody2D

export (Resource) var stats

signal damage_taken(amount)
signal died

var velocity := Vector2.ZERO
var target_velocity := Vector2.ZERO
var acceleration := Vector2.ZERO

var facing_x := 1
var direction_x := facing_x


onready var health: int = stats.max_hp
onready var ap: float = stats.max_ap

onready var state_locked_timer = $StateLockedTimer
onready var state_machine  = $PlayerStateMachine
onready var hud = SceneManager.get_node("HUD")

func _ready():
	$Pivot/BowSprite.visible = false
	$Pivot/ShieldSprite.visible = false
	$PlayerStateMachine/Attack/AttackResetTimer.wait_time = 0.2/stats.atk_speed
	$AnimationPlayer.animation_set_next("Jump to Fall Transition", "Fall")
	hud.max_health = stats.max_hp
	hud.max_ap = stats.max_ap
	hud.change_health_level(health)
	hud.change_ap_level(ap)

func _process(delta):
	$PlayerStateMachine.state.update(delta)
	if ap <= 0:
		ap = 0
		take_damage(1, Vector2.ZERO, self)

func _physics_process(delta):
	$PlayerStateMachine.state.physics_update(delta)
	_move(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(damage:int, knockback:Vector2, _source) -> void:
	if state_machine.state == state_machine.get_node("Shield") and Vector2(facing_x, 0).normalized() == Vector2(_source.global_position.x - global_position.x, 0).normalized():
			state_machine.get_node("Shield").receive_hit()
			if _source.has_method("_enter_stun_state"):
				_source._enter_stun_state()
	else:
		state_machine.transition_to("Hit")
		health -= damage
		velocity = knockback
		hud.change_health_level(health)
		emit_signal("damage_taken", damage)
		if health <= 0:
			emit_signal("died")

func gain_health(amount:int) -> void:
	health += amount
	if health > stats.max_hp:
		health = stats.max_hp
	hud.change_health_level(health)

func gain_ap(amount:float) -> void:
	ap += amount
	if ap > stats.max_ap:
		ap = stats.max_ap
	hud.change_ap_level(ap)

func disable_collision(target) -> void:
	for child in target.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
		disable_collision(child)

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

func unlock_state_switching() -> void:
	state_locked_timer.stop()
	state_machine.state_locked = false

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
		if child.get("no_flip"):
			pass
		else:
			if child.get("position"):
				child.position.x *= -1
			if child is Sprite:
				child.flip_h = sprite_face_left
			if child is RayCast2D:
				child.cast_to.x *= -1
				
		flip_children(direction, child)


func jump(strength_multiplier:=1) -> void:
	gain_ap(-5)
	velocity.y = -stats.jump_strength*strength_multiplier
	global_position.y -= 2

func _get_coyote() -> bool:
	var coyote_timer = $CoyoteTimer
	if coyote_timer.is_stopped():
		return false
	else:
		return true

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
		$CollisionShapeCrouching.set_deferred("disabled", false)
		$CollisionShapeStanding.set_deferred("disabled", true)
	else:
		$CollisionShapeCrouching.set_deferred("disabled", true)
		$CollisionShapeStanding.set_deferred("disabled", false)

func _on_StateLockedTimer_timeout() -> void:
	state_machine.state_locked = false
