extends KinematicBody2D


#enter roam from pursue if walks into wall or about to walk off edge
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
var health: int = max_health
var pursue_target: KinematicBody2D

onready var animation_player = $AnimationPlayer


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

func _roam_state(_delta) -> void:
	apply_gravity(_delta)

func _pursue_state(_delta) -> void:
	if global_position.x - pursue_target.global_position.x < 0:
		set_facing_x(1)
	else:
		set_facing_x(-1)
	velocity.x = move_speed * direction_x

func _attack_state(_delta) -> void:
	pass

func _damaged_state(_delta) -> void:
	pass

func _die_state(_delta) -> void:
	pass





func _enter_roam_state() -> void:
	animation_player.play("Idle")
	state = ROAM

func _enter_pursue_state() -> void:
	animation_player.play("Walk")
	state = PURSUE

func _enter_attack_state() -> void:
	state = ATTACK

func _enter_damaged_state() -> void:
	state = TAKE_HIT

func _enter_die_state() -> void:
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

func _on_PlayerDetector_body_entered(body):
	if body == null:
		return
	if body.is_in_group("Player"):
		pursue_target = body
		_enter_pursue_state()
