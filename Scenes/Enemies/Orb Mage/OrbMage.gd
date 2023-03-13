extends KinematicBody2D

export (int) var max_health

var velocity := Vector2.ZERO
var direction_x := 1

var dodge_range := 20

var pursue_target: KinematicBody2D

var hp_orb = preload("res://Scenes/HpOrb.tscn")
var ap_orb = preload("res://Scenes/ApOrb.tscn")
var attack_orb = preload("res://Scenes/Enemies/Orb Mage/OrbMageAttack.tscn")

onready var health: int = max_health

signal died

func _ready() -> void:
	disable_collision($HitBox)

func _process(_delta) -> void:
	pass

func _physics_process(delta) -> void:
	pass

func take_damage(damage: int, knockback: Vector2, _source) -> void:
	health -= damage
	$StateMachine.transition_to("Hit")

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

func summon_hp_orb() -> void:
	var instance = hp_orb.instance()
	instance.global_position = global_position
	get_node("/root/World").add_child(instance)
	
func summon_ap_orb() -> void:
	var instance = ap_orb.instance()
	instance.global_position = global_position
	get_node("/root/World").add_child(instance)

func summon_attack() -> void:
	var attack_instance = attack_orb.instance()
	attack_instance.global_position = pursue_target.global_position
	get_node("/root/World").add_child(attack_instance)
