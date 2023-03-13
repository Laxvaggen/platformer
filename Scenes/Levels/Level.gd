extends Node2D

var time: float = 0
var damage_taken: int = 0
var kills: int= 0

func _ready() -> void:
	$LevelExit.connect("level_cleared", self, "level_cleared")
	$Player.connect("damage_taken", self, "set_damage_taken")
	$Player.connect("died", self, "level_failed")
	for enemy in _get_enemies():
		enemy.connect("died", self, "enemy_died")

func _process(delta: float) -> void:
	time += delta

func level_cleared() -> void:
	var stats = {"kills":kills, 
					"damage taken": damage_taken,
					"time": round(time*10)/10
					}
	SceneManager._level_cleared(stats)

func level_failed() -> void:
	var stats = [kills, damage_taken, time]
	SceneManager._level_failed(stats)

func _get_enemies() -> Array:
	var enemies: Array
	for child in get_children():
		if child.is_in_group("Enemy"):
			enemies.append(child)
	return enemies

func set_damage_taken(amount) -> void:
	damage_taken += amount

func enemy_died() -> void:
	kills += 1
