extends Node

var active := false
var arrow_instances = []
var arrow_instance: Arrow
var angle_to_mouse: float

var accepted_states := ["Idle", "Walk", "Run", "Crouch", "Air", "WallHang"]
var accuracies: Dictionary
var state: String
var arrow_slot 

onready var pivot = $"../Pivot"
onready var bow = $"../Pivot/BowSprite"

onready var animation_player = $"../Pivot/AnimationPlayer"
onready var player = $".."



func enter(arrow, slot) -> void:
	if !active and arrow != null:
		arrow_slot = slot
		active = true
		animation_player.play("Bow Ready")
		pivot.visible = true
		_summon_arrow(arrow)

func _get_bow_rotation(angle) -> float:
	if !active:
		return round(angle/TAU*64)/64.0*TAU
	if abs(angle) > PI/2:
		player.facing_x = -1
	else:
		player.facing_x = 1
	return round(angle/TAU*64)/64.0*TAU

func _summon_arrow(arrow) -> void:
	var instance = arrow.instance()
	instance.position = pivot.get_node("ArrowSpawn").position
	instance.position.y -= 0.5
	pivot.add_child(instance)
	instance.set_owner(player)
	arrow_instances.append(instance)
	arrow_instance = instance

func update(current_state_id) -> void:
	if active:
		state = current_state_id
		angle_to_mouse = player.get_angle_to(player.get_global_mouse_position())
		pivot.rotation = _get_bow_rotation(angle_to_mouse)
	if pivot.get_children().has(arrow_instance):
		arrow_update()

func arrow_update():
	if abs(angle_to_mouse) > PI/2:
		arrow_instance.flip_v = true
		arrow_instance.position.y = 0.5
	else:
		arrow_instance.flip_v = false
		arrow_instance.position.y = -0.5

func fire() -> void:
	if active:
		animation_player.play("Bow Fire")

func fire_arrow() -> void:
	if arrow_instance == null:
		return
	var angle = pivot.rotation
	var direction = Vector2(cos(angle), sin(angle))
	arrow_instance.velocity = direction*arrow_instance.speed
	arrow_instance.type = player.arrowslots[arrow_slot].arrow
	arrow_instance.fired = true
	pivot.remove_child(arrow_instance)
	get_tree().get_root().get_node("World").add_child(arrow_instance)
	arrow_instance.global_position = pivot.get_node("ArrowSpawn").global_position
	arrow_instance.player = player
	player.arrowslots[arrow_slot].count -= 1
	player.check_slots()
	arrow_instance = null


func exit() -> void:
	pivot.visible = false
	active = false
	animation_player.stop()
	for child in pivot.get_children():
		if child is Arrow:
			child.queue_free()
