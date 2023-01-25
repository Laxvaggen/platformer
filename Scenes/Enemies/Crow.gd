extends KinematicBody2D

enum {ROAM, IDLE}

var orb = preload("res://Scenes/Orb.tscn")

var state = ROAM
var health := 1
var velocity := Vector2.ZERO
var move_speed = 50

onready var animation_player = $AnimationPlayer

func _ready() -> void:
	randomize()
	enter_state_idle()

func _process(delta: float) -> void:
	if health <= 0:
		animation_player.play("Die")
		$Area2D.monitorable = false
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match state:
		ROAM:
			roam_state(delta)
		IDLE:
			idle_state(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(damage, knockback_amount, source) -> void:
	health -= damage
	#velocity = knockback_amount

func select_position() -> void:
	pass

func roam_state(delta) -> void:
	pass

func idle_state(delta) -> void:
	pass

func enter_state_idle() -> void:
	animation_player.play("Idle")
	state = IDLE

func enter_state_roam() -> void:
	animation_player.play("Roam")
	state = ROAM
