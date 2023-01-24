class_name Player
extends KinematicBody2D

export (Resource) var stats

var velocity := Vector2.ZERO

var facing_x := 1
var direction_x := facing_x


var arrowtypes := {"basic": preload("res://Scenes/Arrows/Arrow.tscn")}
#arrow syntax:{"arrow": arrowtypes.type, "count": int}
var arrowslots := [{"arrow": arrowtypes.basic, "count": 3}, {"arrow": null, "count": 0}] 

onready var hp: int = stats.max_hp
onready var sprite = get_node("Sprite")
onready var wallfinder = get_node("WallFinder")
onready var wallfindertop = get_node("WallFinderTop")
onready var bow_sprite = $Pivot/BowSprite
onready var pivot = $Pivot
onready var hud = get_node("/root/World/HUD")


func _ready():
	$Pivot.visible = false
	$Bow.accuracies = {"Crouch":1*stats.accuracy_mult_crouch, 
						"Idle":1*stats.accuracy_mult_idle, 
						"Walk":1*stats.accuracy_mult_walk,
						"Run":1*stats.accuracy_mult_run,
						"Air":1*stats.accuracy_mult_air}

func _process(delta):
	check_slots()
	$PlayerStateMachine.update(delta)
	_flip_children()
	
func _physics_process(delta):
	$PlayerStateMachine.physics_update(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func _flip_children() -> void:
	if facing_x == 1:
		sprite.flip_h = false
		bow_sprite.flip_v = false
		wallfinder.cast_to.x = abs(wallfinder.cast_to.x)
		wallfindertop.cast_to.x = abs(wallfindertop.cast_to.x)
		pivot.position.x = -abs(pivot.position.x)
	else:
		sprite.flip_h = true
		bow_sprite.flip_v = true
		wallfinder.cast_to.x = -abs(wallfinder.cast_to.x)
		wallfindertop.cast_to.x = -abs(wallfindertop.cast_to.x)
		pivot.position.x = abs(pivot.position.x)

func pickup_arrow(arrow:Object) -> void:
	if arrow == null:
		return
	for slot in arrowslots:
		if arrow == slot.arrow:
			slot.count += 1
			return
	for slot in arrowslots:
		if slot.arrow == null:
			slot.arrow = arrow
			slot.count += 1
			return

func check_slots() -> void:
	for slot in arrowslots:
		if slot.count == 0:
			slot.arrow = null
