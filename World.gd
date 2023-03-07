extends Node2D

@onready var scheduler = Scheduler
@onready var player = $Player

const debug_astar = false

func _ready() -> void:
	# randomize() # TODO enable
	scheduler.init_actors()	
	scheduler.start_game()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print('redrawing astar path')
		queue_redraw()

func _draw():
	if not debug_astar:
		return
	var BASE_LINE_WIDTH = 1.0

	var enemies = get_tree().get_nodes_in_group("enemies")
	var enemy: Node2D = enemies[0]
	if not enemy:
		return
	var astar: AStar2D = enemy.astar

	if not astar:
		return
	for point_id in astar.get_point_ids():
		var point := astar.get_point_position(point_id)
		var neighbors = astar.get_point_connections(point_id)
		var pos = Grid.to_world_vec(point)
			
		for neighbor in neighbors:
			var target_pos = Grid.to_world_vec(astar.get_point_position(neighbor))
			
			draw_line(pos, target_pos, Color.BLUE, BASE_LINE_WIDTH, true)

		if astar.is_point_disabled(point_id):
			print("disabled point: ", point_id)
			draw_circle(pos, BASE_LINE_WIDTH * 5, Color.RED)
		else:
			draw_circle(pos, BASE_LINE_WIDTH, Color.BLUE)

	# draw_circle(enemies[0].global_position, BASE_LINE_WIDTH, Color.GREEN)
	# draw_circle(Grid.to_world_vec(Vector2(5,5)), BASE_LINE_WIDTH, Color.GREEN)
	
	var goblin_coords = enemies[0].get_board_coord()
	var player_coords = player.get_board_coord()
	var path = astar.get_point_path(
		Board.get_id(goblin_coords.x, goblin_coords.y), 
		Board.get_id(player_coords.x,player_coords.y)
	)
	var path_in_world_coords = Fp.map(path, func(x): return Grid.to_world_vec(x))
	# draw_polyline(path_in_world_coords, Color.RED, 10.0)
	
