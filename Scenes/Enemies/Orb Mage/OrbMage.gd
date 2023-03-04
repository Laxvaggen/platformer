extends KinematicBody2D

"""
stand still, summon OrbMageAttacks

when player gets too close, use other attack, then teleport to new location
"""


enum {IDLE, RANGED_ATTACK, ATTACK, TAKE_HIT, DIE}

var state: int = IDLE

export (int) var max_health
export (int) var move_speed
export (int) var ground_acceleration
export (int) var gravity_acceleration
export (int) var max_fall_speed

var velocity := Vector2.ZERO
var direction_x := 1
var teleport_range := 50

var dodge_range := 30

var pursue_target: KinematicBody2D
var state_locked := false

var ranged_attack = preload("res://Scenes/Enemies/Orb Mage/OrbMageAttack.tscn")

onready var animation_player = $AnimationPlayer
onready var health: int = max_health

func _ready() -> void:
	_enter_idle_state()

func _process(_delta) -> void:
	pass

func _physics_process(delta) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RANGED_ATTACK:
			_ranged_attack_state(delta)
		ATTACK:
			_attack_state(delta)
		TAKE_HIT:
			_take_hit_state(delta)
		DIE:
			_die_state(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func apply_gravity(delta) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity_acceleration*delta)

func lock_state_switching(time:float) -> void:
	assert(time>0)
	state_locked = true
	yield(get_tree().create_timer(time), "timeout")
	state_locked = false

func take_damage(damage: int, knockback: Vector2, _source) -> void:
	health -= damage
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

func _summon_attack():
	if not pursue_target is KinematicBody2D:
		return
	var instance = ranged_attack.instance()
	instance.global_position = pursue_target.global_position
	get_node("/root/World").add_child(instance)

func _teleport() -> void:
	var teleport_angle := rand_range(-PI, PI)
	var teleport_position := Vector2(cos(teleport_angle), sin(teleport_angle))*rand_range(0, teleport_range)
	
	#select random position within range
	#use raycast to find ground 
	#teleport to raycast .get_collider
	

func _idle_state(delta) -> void:
	_apply_gravity(delta)
	if can_see_target(pursue_target):
		_enter_ranged_attack_state()

func _ranged_attack_state(delta) -> void:
	_apply_gravity(delta)
	if pursue_target == null:
		_enter_idle_state()
		return
	var distance_to_target = get_distance_to_target(pursue_target)
	if global_position.x - pursue_target.global_position.x < 0:
		set_facing_x(1)
	else:
		set_facing_x(-1)
	if distance_to_target < 0:
		pass
	elif distance_to_target < dodge_range:
		_enter_attack_state()
	elif $AttackCooldown.is_stopped():
		animation_player.play("Attack")
		$AttackCooldown.start()


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

func _enter_idle_state() -> void:
	animation_player.play("Idle", -1, 0.5)
	velocity = Vector2.ZERO
	state = IDLE

func _enter_ranged_attack_state() -> void:
	animation_player.play("Idle", -1, 0.5)
	state = RANGED_ATTACK

func _enter_attack_state() -> void:
	animation_player.play("Sweep Attack")
	velocity = Vector2.ZERO
	state = ATTACK

func _enter_take_hit_state() -> void:
	animation_player.play("Hit")
	state = TAKE_HIT
	yield($AnimationPlayer, "animation_finished")
	for body in $Vision.get_overlapping_bodies():
		if body.is_in_group("Player"):
			_enter_ranged_attack_state()
			return
	_enter_idle_state()

func _enter_die_state() -> void:
	velocity = Vector2.ZERO
	animation_player.play("Hit")
	animation_player.queue("Die")
	disable_collision(self)
	state = DIE

func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		pursue_target = body
		$Targeter.enabled = true


func _on_Vision_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		pursue_target = null
		$Targeter.enabled = false

