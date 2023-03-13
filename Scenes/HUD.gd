extends CanvasLayer

var health: float
var max_health: int

var ap: float
var max_ap: int


func change_health_level(value) -> void:
	health = value
	$HealthBar.value = 18 + health/max_health*(82-18)

func change_ap_level(value) -> void:
	ap = value
	$ApBar.value = 2 + ap/max_ap*(86-2)
