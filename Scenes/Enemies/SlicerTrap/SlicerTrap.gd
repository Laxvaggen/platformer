extends Node2D

onready var animation_player = $AnimationPlayer

func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		yield(get_tree().create_timer(0.3), "timeout")
		animation_player.animation_set_next("Attack", "Return")
		animation_player.animation_set_next("Return", "Idle")
		animation_player.play("Attack")
