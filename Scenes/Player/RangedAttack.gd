extends PlayerState

#Can idle, walk, run, crouch, air
enum {IDLE, CROUCH, WALK, RUN, AIR}

var state := IDLE
onready var coyote_timer = $"../../CoyoteTimer"
var coyote := false


onready var pivot = $"../../Pivot"


func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	set_rotation(player.get_angle_to(player.get_global_mouse_position()))
	match state:
		IDLE:
			_bow_idle_state(_delta)
		CROUCH:
			_bow_crouch_state(_delta)
		WALK:
			_bow_walk_state(_delta)
		RUN:
			_bow_run_state(_delta)
		AIR:
			_bow_air_state(_delta)

func set_rotation(angle) -> void:
	if abs(angle) > PI/2:
		player.set_facing_x(-1)
		pivot.get_node("BowSprite").flip_v = true
		pivot.position.x = pivot.absolute_position.x * -1
		
		
	else:
		player.set_facing_x(1)
		pivot.get_node("BowSprite").flip_v = false
		pivot.position.x = pivot.absolute_position.x * 1
	pivot.position.y = pivot.absolute_position.y
	pivot.rotation = angle

func _get_next_state() -> void:
	if !Input.is_action_pressed("ranged attack"):
		pivot.get_node("AnimationPlayer").play("Bow Fire")
		yield(pivot.get_node("AnimationPlayer"), "animation_finished")
		if player.is_on_ground():
			state_machine.transition_to("Idle")
			return
		else:
			state_machine.transition_to("Air")



func enter(_msg := {}) -> void:
	pivot.get_node("BowSprite").visible = true
	pivot.get_node("AnimationPlayer").play("Bow Ready")

func exit() -> void:
	pivot.get_node("BowSprite").visible = false

func _bow_idle_state(_delta:float) -> void:
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		player.set_facing_x(get_direction_x(), true)
		if Input.is_action_pressed("sprint"):
			_enter_run_state()
			return
		else:
			_enter_walk_state()
			return
	
	if Input.is_action_pressed("jump"):
		_enter_air_state({do_jump=true})
		return
	
	if Input.is_action_pressed("crouch"):
		if player.is_on_platform():
			_enter_air_state({drop=true})
		else:
			_enter_crouch_state()
		return

	if !player.is_on_floor():
		_enter_air_state()
		return

func _bow_crouch_state(_delta:float) -> void:
	if !Input.is_action_pressed("crouch") and !player.low_ceiling():
			_enter_idle_state()
			player.set_collision_shape("high")
			return

func _bow_walk_state(_delta:float) -> void:
	player.set_target_velocity(player.stats.walk_speed*get_direction_x(), player.stats.ground_acceleration)
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		_enter_idle_state()
		return
	if Input.is_action_just_pressed("sprint"):
		_enter_run_state()
		return
	if Input.is_action_pressed("jump"):
		_enter_air_state({do_jump=true})
		return
	if Input.is_action_pressed("crouch"):
		if player.is_on_platform():
			_enter_air_state({drop=true})
		else:
			_enter_crouch_state()
		return
	if !player.is_on_ground():
		_enter_air_state()
		return

func _bow_run_state(_delta:float) -> void:
	if get_direction_x() != player.facing_x:
		player.set_target_velocity(player.stats.walk_speed*get_direction_x(), player.stats.ground_acceleration)
		animation_player.play("Walk")
	else:
		player.set_target_velocity(player.stats.run_speed*get_direction_x(), player.stats.ground_acceleration)
		animation_player.play("Run")
	
	if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		animation_player.play("Run Stop")
		_enter_idle_state({unforce_animation=true})
		return
	if Input.is_action_pressed("jump"):
		_enter_air_state({do_jump=true})
		return
	if Input.is_action_pressed("crouch") and player.is_on_platform():
		_enter_air_state({drop=true})
		return
	if !Input.is_action_pressed("sprint"):
		_enter_walk_state()
		return
	if !player.is_on_ground():
		_enter_air_state()
		return

func _bow_air_state(_delta:float) -> void:
	player.set_target_velocity(player.stats.air_speed*get_direction_x(), player.stats.air_acceleration, 
								player.stats.max_fall_speed, player.stats.gravity_acceleration)
	if animation_player.current_animation == "Jump" and player.velocity.y >= 0:
		animation_player.play("Fall")
	if Input.is_action_just_pressed("jump") and coyote:
		animation_player.play("Jump")
		player.jump()
		coyote_timer.stop()
		coyote = false
	if player.is_on_ground():
		_enter_idle_state()
		return

func _enter_idle_state(_msg:={}) -> void:
	state = IDLE
	if !_msg.has("unforce_animation"):
		animation_player.play("Idle")
	else:
		animation_player.queue("Idle")

func _enter_crouch_state(_msg:={}) -> void:
	state = CROUCH
	animation_player.play("Crouch")
	player.set_collision_shape("low")

func _enter_walk_state(_msg:={}) -> void:
	state = WALK
	animation_player.play("Walk")

func _enter_run_state(_msg:={}) -> void:
	state = RUN
	animation_player.play("Run")

func _enter_air_state(_msg:={}) -> void:
	state = AIR
	if _msg.has("do_jump"):
		animation_player.play("Jump")
		player.jump()
	elif _msg.has("drop"):
		player.global_position.y += 2
		animation_player.play("Fall")
		player.lock_state_switching(0.2)
	else:
		animation_player.play("Fall")
		coyote_timer.start()
		coyote = true
