class_name Player
extends KinematicBody2D

export (Resource) var stats

var velocity := Vector2.ZERO

var facing_x := 1
var direction_x := facing_x

onready var hp: int = stats.max_hp


func _ready():
	$Pivot.visible = false
	$AttackResetTimer.wait_time = 0.2/stats.atk_speed

func _process(delta):
	$PlayerStateMachine.state.update(delta)
	
func _physics_process(delta):
	$PlayerStateMachine.state.physics_update(delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func attack_reposition(value:int) -> void:
	global_position.x += value * facing_x
