extends StateMachine

var player: Player
var state_locked := false


func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)
	for child in get_children():
		child.state_machine = self
	state.enter()
