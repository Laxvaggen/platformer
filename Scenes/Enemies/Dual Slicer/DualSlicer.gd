extends KinematicBody2D


#enter attack from pursue if in range to hit player (with animation first playing a "!" warning)
#roam is walk back and forth, turning around at some range or when hitting edge or wall

enum {ROAM, PURSUE, ATTACK, TAKE_HIT, DIE}

var state: int = ROAM

export (int) var max_health
export (int) var move_speed
export (int) var ground_acceleration
export (int) var gravity_acceleration
export (int) var max_fall_speed

var velocity := Vector2.ZERO
var direction_x := 1

var pursue_target: KinematicBody2D
var attack_range: = 35
var start_attack_combo_range: = 20
var last_attack := 0
var state_locked := false


onready var animation_player = $AnimationPlayer
onready var health: int = max_health


func _ready() -> void:
	_enter_roam_state()

func _process(delta) -> void:
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
			_damaged_state(delta)
		DIE:
			_die_state(delta)
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

func start_attack() -> void:
	animation_player.play("Attack")

func pause_attacks() -> void:
	assert(animation_player.current_animation == "Attack")
	animation_player.stop(false)
	$AttackCooldown.start()

func take_damage(damage: int, knockback: Vector2) -> void:
	
	health -= damage
	if state == ATTACK:
		_exit_attack_state()
	_enter_damaged_state(knockback)

func _roam_state(_delta) -> void:
	apply_gravity(_delta)

func _pursue_state(_delta) -> void:
	if not pursue_target is KinematicBody2D:
		_enter_roam_state()
		return
	if !is_on_ground() or is_on_wall():
		_enter_roam_state()
		velocity = Vector2.ZERO
		return
	if (global_position - pursue_target.global_position).length() <= start_attack_combo_range:
		_enter_attack_state()
		velocity = Vector2.ZERO
		return
	if global_position.x - pursue_target.global_position.x < 0:
		set_facing_x(1)
	else:
		set_facing_x(-1)
	velocity.x = move_speed * direction_x


func _attack_state(_delta) -> void:
	pass

func _damaged_state(_delta) -> void:
	apply_gravity(_delta)
	yield(animation_player, "animation_finished")
	_enter_pursue_state()

func _die_state(_delta) -> void:
	apply_gravity(_delta)

func _enter_roam_state() -> void:
	animation_player.play("Idle")
	state = ROAM

func _enter_pursue_state() -> void:
	animation_player.play("Walk")
	state = PURSUE

func _enter_attack_state() -> void:
	start_attack()
	state = ATTACK

func _enter_damaged_state(knockback) -> void:
	animation_player.play("Hit")
	velocity = knockback
	if health <= 0:
		_enter_die_state()
		return
	state = TAKE_HIT

func _exit_attack_state() -> void:
	for child in $HitBox.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	$VFXSprite.visible = false

func _enter_die_state() -> void:
	state_locked = true
	animation_player.queue("Die")
	velocity = Vector2.ZERO
	state = DIE

func set_facing_x(direction, force_look_forward=true) -> void:
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


func _on_PlayerDetector_body_entered(body: Node) -> void:
	if state_locked:
		return
	if body.is_in_group("Player"):
		if state == ATTACK:
			_exit_attack_state()
		pursue_target = body
		_enter_pursue_state()

func _on_AttackCooldown_timeout() -> void:
	if state != ATTACK:
		return
	if (global_position - pursue_target.global_position).length() > attack_range:
		if state == ATTACK:
			_exit_attack_state()
		_enter_pursue_state()
		return
	else:
		animation_player.play()
