class_name Arrow
extends KinematicBody2D

var flip_v := false
var fired := false
var collided := false
var picked_up := false
var velocity = Vector2.ZERO


var speed: int = 400
var gravity := 200
var damage: int= 25
var knockback_amount: int = 100

var player
var type

onready var hurtbox = $HurtBox
onready var tween = $Tween

func _ready() -> void:
	pass

func _process(_delta) -> void:
	$Sprite.flip_v = flip_v

func _physics_process(delta) -> void:
	if fired and !collided:
		flip_v = false
		$Sprite.rotation = velocity.angle()
		_add_gravity(gravity, delta)
		velocity = move_and_slide(velocity, Vector2.UP)
	elif picked_up:
		global_position = global_position.move_toward(player.global_position, 100*delta)
	elif owner != null:
		if owner.is_in_group("Enemy") and owner.health <= 0:
			call_deferred("_return_to_world")

func _add_gravity(magnitude, delta) -> void:
	velocity.y += magnitude*delta

func _stick(area) -> void:
	position = global_position - area.global_position
	get_parent().remove_child(self)
	area.owner.add_child(self)

func _return_to_world() -> void:
	position = global_position
	var end = get_tree().get_root().get_node("World")
	get_parent().remove_child(self)
	end.add_child(self)
	collided = false

func _on_HurtBox_area_entered(area):
	if !fired:
		return
	if area.owner.is_in_group("Enemy") and !collided:
		area.owner.take_damage(25, knockback_amount, self)
		
		if area.owner.health <= 0:
			call_deferred("_return_to_world")
		else:
			call_deferred("_stick", area)
		velocity = Vector2.ZERO
		collided = true
	elif area.owner == player and collided:
		picked_up = true
		tween.interpolate_property(self, "scale",
		Vector2(1, 1), Vector2(0, 0), 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		$PickupTimer.start()

func _on_HurtBox_body_entered(body):
	if !fired:
		return
	if body.is_in_group("Level"):
		velocity = Vector2.ZERO
		collided = true


func _on_PickupTimer_timeout():
	player.pickup_arrow(type)
	player.get_node("Bow").arrow_instance = null
	queue_free()
