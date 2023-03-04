extends KinematicBody2D


#enter attack from pursue if in range to hit player (with animation first playing a "!" warning)
#roam is walk back and forth, turning around at some range or when hitting edge or wall

enum {ROAM, PURSUE, ATTACK, TAKE_HIT, DIE, DODGE, STUN}

var state: int = ROAM

export (int) var max_health
export (int) var move_speed
export (int) var ground_acceleration
export (int) var gravity_acceleration
export (int) var max_fall_speed

var velocity := Vector2.ZERO
var direction_x := 1

var dodge_range := 15

var pursue_target: KinematicBody2D
var last_attack := 0
var state_locked := false


onready var animation_player = $AnimationPlayer
onready var health: int = max_health
onready var attack_range = $AttackRange


func _ready() -> void:
	_enter_roam_state()

func _process(_delta) -> void:
	pass

func _physics_process(delta) -> void:
	match state:
		ROAM:
			_roam_state(delta)
		PURSUE:
			_pursue_state(delta)
		ATTACK:
			_attack_state(delta)
		TAKE_HIT:
			_take_hit_state(delta)
		DIE:
			_die_state(delta)
		DODGE:
			_dodge_state(delta)
		STUN:
			_stun_state(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func apply_gravity(delta) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity_acceleration*delta)

func is_on_ground() -> bool:
	var val := false
	var ground_finder = $GroundFinder
	ground_finder.enabled = true
	ground_finder.force_raycast_update()
	if ground_finder.is_colliding() and ground_finder.get_collider().is_in_group("Level"):
		val = true
	ground_finder.enabled = false
	return val

func lock_state_switching(time:float) -> void:
	assert(time>0)
	state_locked = true
	yield(get_tree().create_timer(time), "timeout")
	state_locked = false

func pause_attacks(time:float=0.3) -> void:
	if state == STUN:
		animation_player.play("Idle")
		$VFXSprite.visible = false
		return
	animation_player.stop(false)
	if !attack_range.get_overlapping_bodies().has(pursue_target):
		_enter_pursue_state()
		$VFXSprite.visible = false
		disable_collision($HitBox)
	yield(get_tree().create_timer(time), "timeout")
	animation_player.play()

func take_damage(damage: int, knockback: Vector2, _source) -> void:
	health -= damage
	$VFXSprite.visible = false
	if health <= 0:
		_enter_die_state()
	else:
		_enter_take_hit_state()
		velocity = knockback

func can_see_target(target:KinematicBody2D) -> bool:
	var raycast = $Targeter
	if target == null:
		return false
	raycast.cast_to = target.position-position
	if raycast.get_collider() == null:
		return false
	if raycast.get_collider().is_in_group("Player"):
		return true
	else:
		return false

func _apply_gravity(delta) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity_acceleration*delta)

func get_distance_to_target(target:KinematicBody2D) -> float:
	var raycast = $Targeter
	raycast.cast_to = target.position-position
	raycast.force_raycast_update()
	if raycast.get_collider() == null or target == null:
		return -1.0
	if !raycast.get_collider().is_in_group("Player"):
		return -1.0
	var vector = raycast.get_collision_point() - global_position
	return vector.length()

func set_facing_x(direction:int) -> void:
	if !abs(direction) == 1:
		return
	if direction == direction_x:
		return

	flip_children(direction, self)
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

func disable_collision(target) -> void:
	for child in target.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
		disable_collision(child)

func _roam_state(delta) -> void:
	_apply_gravity(delta)
	if can_see_target(pursue_target):
		_enter_pursue_state()

func _pursue_state(delta) -> void:
	_apply_gravity(delta)
	if pursue_target == null:
		_enter_roam_state()
		return
	var distance_to_target = get_distance_to_target(pursue_target)
	if global_position.x - pursue_target.global_position.x < 0:
		set_facing_x(1)
	else:
		set_facing_x(-1)
	if distance_to_target < 0:
		pass
	elif distance_to_target < dodge_range and is_on_ground():
		_enter_dodge_state()
	elif !attack_range.get_overlapping_bodies().has(pursue_target):
		velocity.x = move_speed * direction_x
	else:
		_enter_attack_state()
		return


func _attack_state(delta) -> void:
	_apply_gravity(delta)

func _take_hit_state(delta) -> void:
	_apply_gravity(delta)
	#velocity.x move toward zero
	#wait for animation player, then return to attack state
	pass
	#play when hit, must override other states. Careful when cancelling animation player animations

func _die_state(_delta) -> void:
	pass
	#disable hurtbox & shape, play die animation, queue free

func _dodge_state(delta) -> void:
	_apply_gravity(delta)
	if !state_locked:
		_enter_pursue_state()

func _stun_state(delta) -> void:
	_apply_gravity(delta)
	if !state_locked:
		$StunFXSprite.visible = false
		_enter_pursue_state()


func _enter_roam_state() -> void:
	animation_player.play("Idle")
	velocity = Vector2.ZERO
	state = ROAM

func _enter_pursue_state() -> void:
	animation_player.play("Walk")
	state = PURSUE

func _enter_attack_state() -> void:
	if $AttackCooldown.time_left > 0:
		return
	animation_player.play("Attack")
	$AttackCooldown.start()
	velocity = Vector2.ZERO
	state = ATTACK

func _enter_take_hit_state() -> void:
	animation_player.play("Hit")
	state = TAKE_HIT
	yield($AnimationPlayer, "animation_finished")
	for body in $Vision.get_overlapping_bodies():
		if body.is_in_group("Player"):
			_enter_pursue_state()
			return
	_enter_roam_state()

func _enter_die_state() -> void:
	velocity = Vector2.ZERO
	animation_player.play("Hit")
	animation_player.queue("Die")
	disable_collision(self)
	state = DIE

func _enter_dodge_state() -> void:
	velocity.x = -move_speed * 2.5 * direction_x
	velocity.y = -50
	animation_player.play("Hit")
	animation_player.queue("Walk")
	lock_state_switching(0.3)
	state = DODGE

func _enter_stun_state() -> void:
	state = STUN
	$StunFXSprite.visible = true
	lock_state_switching(1)

func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		pursue_target = body
		$Targeter.enabled = true


func _on_Vision_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		pursue_target = null
		$Targeter.enabled = false
