extends Area2D

export (int) var amount

var velocity: Vector2
var player: KinematicBody2D

var initial = true

func _ready() -> void:
	randomize()
	velocity = Vector2(rand_range(-100, 100), rand_range(-100, 100))
	player = get_tree().get_root().get_node("World/Player")
	
func _physics_process(delta: float) -> void:
	if initial:
		global_position += velocity * delta
		velocity *= 0.96
	else:
		var vector_to_player = (player.global_position-global_position).normalized()
		global_position += vector_to_player * 8

func _on_Timer_timeout() -> void:
	initial = false


func _on_HpOrb_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		body.gain_health(amount)
		queue_free()
