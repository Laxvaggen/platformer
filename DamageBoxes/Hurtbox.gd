class_name HurtBox
extends Area2D

var invincibility = false

func _init() -> void:
	collision_layer = 0
	collision_mask = 2



func _ready():
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	elif hitbox.owner == owner:
		return
	elif invincibility: 
		return
	var knockback_vector := Vector2(0, -0.5)
	if global_position.x - hitbox.global_position.x < 0:
		knockback_vector.x = -1
	else:
		knockback_vector.x = 1
	knockback_vector = knockback_vector.normalized()
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage, knockback_vector*hitbox.knockback, hitbox.owner)
		invincibility = true
		yield(get_tree().create_timer(0.1),"timeout")
		if owner != null:
			invincibility = false
