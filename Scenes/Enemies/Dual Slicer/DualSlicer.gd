extends KinematicBody2D

enum {ROAM, PURSUE, ATTACK, TAKE_HIT, DIE}

var state: int = ROAM

export (int) var max_health
export (int) var move_speed
export (int) var ground_acceleration
export (int) var gravity_acceleration
export (int) var max_fall_speed

var velocity := Vector2.ZERO
var health: int = max_health

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
	pass

func _attack_state(_delta) -> void:
	pass

func _damaged_state(_delta) -> void:
	pass

func _die_state(_delta) -> void:
	pass





func _enter_roam_state() -> void:
	animation_player.play("Walk")

func _enter_pursue_state() -> void:
	pass

func _enter_attack_state() -> void:
	pass

func _enter_damaged_state() -> void:
	pass

func _enter_die_state() -> void:
	pass
