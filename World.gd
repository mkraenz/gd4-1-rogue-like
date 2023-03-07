extends Node2D

@onready var scheduler = Scheduler
@onready var tilemap = $TileMap

var astar: AStar2D

func _ready() -> void:
	# randomize() # TODO enable
	scheduler.init_actors()	
	scheduler.start_game()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print('mouse pressed')
		# queue_redraw()

func _draw():

	var BASE_LINE_WIDTH = 3.0

	var enemies = get_tree().get_nodes_in_group("enemies")
	astar = enemies[0].astar

	if not astar:
		return
	for point_id in astar.get_point_ids():
		var point := astar.get_point_position(point_id)
		var neighbors = astar.get_point_connections(point_id)
		var pos = Grid.to_world_vec(point)
		if astar.is_point_disabled(point_id):
			draw_circle(pos, BASE_LINE_WIDTH * 2.0, Color.RED)
		else:
			draw_circle(pos, BASE_LINE_WIDTH * 2.0, Color.BLUE)
			
		for neighbor in neighbors:
			var target_pos = Grid.to_world_vec(astar.get_point_position(neighbor))
			
			draw_line(pos, target_pos, Color.BLUE, BASE_LINE_WIDTH, true)

	draw_circle(enemies[0].global_position, BASE_LINE_WIDTH * 2.0, Color.GREEN)
	draw_circle(Grid.to_world_vec(Vector2(5,5)), BASE_LINE_WIDTH * 2.0, Color.GREEN)
	
	var goblin_coords = enemies[0].get_board_coord()
	var path = astar.get_point_path(Board.get_id(goblin_coords.x, goblin_coords.y), Board.get_id(5, 5))
	var path_in_world_coords = Fp.map(path, func(x): return Grid.to_world_vec(x))
	draw_polyline(path_in_world_coords, Color.RED, 18.0)
	
