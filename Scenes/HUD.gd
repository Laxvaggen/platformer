extends CanvasLayer

onready var player = get_node("/root/World/Player")
onready var arrow_containers = [$ArrowContainer1, $ArrowContainer2]

func _process(_delta) -> void:
	return
	for i in range(player.arrowslots.size()):
		
		if player.arrowslots[i].arrow == null:
			arrow_containers[i].get_node("Sprite").texture = null
			arrow_containers[i].get_node("Count").text = ""
		else:
			arrow_containers[i].get_node("Sprite").texture = player.arrowslots[i].arrow.instance().get_node("Sprite").texture
			arrow_containers[i].get_node("Count").text = str(player.arrowslots[i].count)
