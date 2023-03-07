extends Area2D

signal player_detected(player)
signal player_lost

# the area is still a square, so it might be up to 10 + a few cells away if the player is in the corner
@export var range_in_cells = 10

func _ready():
	$Shape.shape.size = Vector2(range_in_cells * Grid.step_x, range_in_cells * Grid.step_y)

func _on_body_exited(body:Node2D):
	if body is Player:
		player_lost.emit()

func _on_body_entered(body:Node2D):
	if body is Player:
		player_detected.emit(body)
