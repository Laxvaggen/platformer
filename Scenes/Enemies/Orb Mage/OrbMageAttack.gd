extends Node2D

onready var ground_finder = $GroundFinder

func _ready() -> void:
	ground_finder.force_raycast_update()
	if !ground_finder.is_colliding():
		queue_free()
	global_position = ground_finder.get_collision_point()
	ground_finder.enabled = false
	$AnimatedSprite.play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
