extends Area2D

func _ready():
	assert(owner is KinematicBody2D)

func take_damage(damage:int, knockback_amount:int, entity:KinematicBody2D):
	owner.hp -= damage
	owner.velocity = Vector2(owner.global_position - entity.global_position).normalized() * knockback_amount
