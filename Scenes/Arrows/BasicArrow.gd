extends KinematicBody2D

var velocity: Vector2
var gravity_acceleration: int
var max_fall_speed: int
var fired := false

export (bool) var no_flip

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if fired:
		$Sprite.rotation = velocity.angle()
		velocity.y += gravity_acceleration
		if velocity.y >= max_fall_speed:
			velocity.y = max_fall_speed
		velocity = move_and_slide(velocity, Vector2.UP)

func _on_ActivationTimer_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
	$HitBox/CollisionShape2D.set_deferred("disabled", false)
	$GroundDetector/CollisionShape2D.set_deferred("disabled", false)


func _on_GroundDetector_body_entered(body: Node) -> void:
	queue_free()


func _on_HitBox_area_entered(area: Area2D) -> void:
	queue_free()
