extends Node2D

var rays: Array
var base_radius: int = 25
var radius: float = base_radius

var charging

var collision_points: Array

var explosion = preload("res://Scenes/Player/Bow Shot/Explosion.tscn")

export (bool) var no_flip

func _ready() -> void:
	visible = false
	for child in get_children():
		if child is RayCast2D:
			rays.append(child)
	

func _physics_process(delta: float) -> void:
	_set_lasers()
	if charging:
		if radius >= 0:
			radius -= delta * 6
		if $AnimationPlayer.playback_speed <= 4:
			$AnimationPlayer.playback_speed += delta


func charge_shot() -> void:
	$AnimationPlayer.play("Charge")
	visible = true
	radius = base_radius
	$AnimationPlayer.playback_speed = 0.5
	for ray in rays:
		ray.get_node("Line2D").width = 2
		ray.get_node("Line2D").default_color.a = 0.196
	charging = true

func release_shot() -> void:
	$AnimationPlayer.play("Fire")
	charging = false
	collision_points = []
	for ray in rays:
		ray.force_raycast_update()
		collision_points.append(ray.get_collision_point())
	yield(get_tree().create_timer(0.2), "timeout")
	_explode()

func _set_lasers() -> void:
	for ray in rays:
		ray.cast_to.y = radius * ray.position.y
		ray.force_raycast_update()
		ray.get_node("Line2D").set_point_position(0, ray.position)
		if ray.is_colliding():
			ray.get_node("Line2D").set_point_position(1, to_local(ray.get_collision_point()))
		else:
			ray.get_node("Line2D").set_point_position(1, ray.cast_to)



func _explode() -> void:
	for location in collision_points:
		var explosion_instance = explosion.instance()
		explosion_instance.global_position = location
		get_node("/root/World").add_child(explosion_instance)

func stop() -> void:
	$AnimationPlayer.stop()
	visible = false
