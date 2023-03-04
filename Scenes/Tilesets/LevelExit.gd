extends Node2D

signal level_cleared

func _ready() -> void:
	z_index = 1

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		$"Ancient Caves Portal".play("use")
		$"Blood Temple Portal".play("use")


func _on_Blood_Temple_Portal_animation_finished() -> void:
	if $"Blood Temple Portal".animation != "use":
		return
	emit_signal("level_cleared")
