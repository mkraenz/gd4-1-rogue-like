extends StaticBody2D

func add_to_board() -> void:
	print('wall added to board')
	Board.add_from_world(global_position, self)

func _ready():
	add_to_board()	

