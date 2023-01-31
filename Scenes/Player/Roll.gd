extends PlayerState

#Available states for transition: Idle

func update(_delta: float) -> void:
	_get_next_state()

func physics_update(_delta: float) -> void:
	pass

func _get_next_state() -> void:
	pass

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
