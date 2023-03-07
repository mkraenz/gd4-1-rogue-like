extends Area2D

signal player_detected(player)
signal player_lost

func _on_body_exited(body:Node2D):
	if body is Player:
		player_lost.emit()

func _on_body_entered(body:Node2D):
	if body is Player:
		player_detected.emit(body)
