extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	Eventbus.connect("player_died", _on_player_died)

func _on_player_died():
	show()