extends Node2D


func _ready() -> void:
	$"Ancient Caves Portal".play("use")
	$"Blood Temple Portal".play("use")



func _on_Blood_Temple_Portal_animation_finished() -> void:
	$"Ancient Caves Portal".animation = "idle"
	$"Blood Temple Portal".animation = "idle"
