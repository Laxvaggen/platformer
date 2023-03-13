extends Node2D

func _ready() -> void:
	$AnimatedSprite.play("default")
	$HitBox/CollisionShape2D.set_deferred("disabled", true)

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()


func _on_HitboxActivationTimer_timeout() -> void:
	$HitBox/CollisionShape2D.set_deferred("disabled", false)
	


func _on_HitboxDeactivationTimer_timeout() -> void:
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
