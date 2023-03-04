extends KinematicBody2D

enum {IDLE, ATTACK, TAKE_HIT, DIE}

var state: int = IDLE

export (int) var max_health
export (int) var move_speed
export (int) var ground_acceleration
export (int) var gravity_acceleration
export (int) var max_fall_speed

var velocity := Vector2.ZERO

var state_locked := false


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
		ATTACK:
			_attack_state(delta)
		TAKE_HIT:
			_take_hit_state(delta)
		DIE:
			_die_state(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

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

func _apply_gravity(delta) -> void:
	velocity.y = move_toward(velocity.y, max_fall_speed, gravity_acceleration*delta)

func disable_collision(target) -> void:
	for child in target.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
		disable_collision(child)

func _idle_state(delta) -> void:
	_apply_gravity(delta)
	pass

func _attack_state(delta) -> void:
	_apply_gravity(delta)

func _take_hit_state(delta) -> void:
	_apply_gravity(delta)
	pass

func _die_state(_delta) -> void:
	pass

func _enter_idle_state() -> void:
	animation_player.play("Move", -1, 0.25)
	velocity = Vector2.ZERO
	state = IDLE

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
	_enter_idle_state()

func _enter_die_state() -> void:
	velocity = Vector2.ZERO
	animation_player.play("Hit")
	animation_player.queue("Die")
	disable_collision(self)
	state = DIE


func _on_Vision_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and state == IDLE:
		_enter_attack_state()
