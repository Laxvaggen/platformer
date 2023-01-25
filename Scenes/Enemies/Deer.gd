extends KinematicBody2D

enum {ROAM, IDLE, EAT}

var orb = preload("res://Scenes/Orb.tscn")

var state = ROAM
var health := 1
var velocity := Vector2.ZERO
var move_speed = 50

onready var animation_player = $AnimationPlayer
onready var state_switch_timer = $StateSwitchTimer

func _ready() -> void:
	randomize()
	enter_state_idle()

func _process(delta: float) -> void:
	if health <= 0:
		animation_player.play("Die")
		$Area2D.monitorable = false
		velocity = Vector2.ZERO

	if $Sprite.flip_h:
		$GroundFinder.position.x = -abs($GroundFinder.position.x)
		$WallFinder.cast_to.x = -abs($WallFinder.cast_to.x )
	else:
		$GroundFinder.position.x = abs($GroundFinder.position.x)
		$WallFinder.cast_to.x = abs($WallFinder.cast_to.x )

func _physics_process(delta: float) -> void:
	match state:
		ROAM:
			roam_state(delta)
		IDLE:
			idle_state(delta)
		EAT:
			eat_state(delta)
	velocity.y += 200*delta
	velocity = move_and_slide(velocity, Vector2.UP)

func take_damage(damage, knockback_amount, source) -> void:
	health -= damage
	#velocity = knockback_amount

func _get_next_state() -> void:
	if state == IDLE:
		if randi() % 2 == 0:
			enter_state_eat()
		else:
			enter_state_roam()
	elif randi() % 2 == 0:
		animation_player.stop()
		if state == EAT:
			exit_state_eat()
			enter_state_idle()
		elif state == ROAM:
			exit_state_roam()
			enter_state_idle()

func roam_state(delta) -> void:
	if $WallFinder.is_colliding() or !$GroundFinder.is_colliding():
		$Sprite.flip_h = !$Sprite.flip_h
		velocity.x *= -1
		#global_position.x += velocity.x

func idle_state(delta) -> void:
	pass

func eat_state(delta) -> void:
	pass

func enter_state_idle() -> void:
	animation_player.queue("Idle")
	state = IDLE

func enter_state_roam() -> void:
	animation_player.queue("Walk")
	state = ROAM
	if randi() % 2 == 0:
		$Sprite.flip_h = true
		velocity.x = move_speed*-1
	else:
		$Sprite.flip_h = false
		velocity.x = move_speed

func enter_state_eat() -> void:
	animation_player.play("Idle to Eat Transition")
	animation_player.queue("Eat")
	state = ROAM

func exit_state_eat() -> void:
	animation_player.play("Eat to Idle Transition")

func exit_state_roam() -> void:
	velocity.x = 0

func _on_StateSwitchTimer_timeout() -> void:
	state_switch_timer.start()
	_get_next_state()
