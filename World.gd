extends Node2D

func _ready():
	var player = $Player
	Scheduler.add(player)
	var enemy = $Enemy
	Scheduler.add(enemy)

extends Node2D

const Dwarf = preload("res://Npcs/Dwarf.tscn")
const Goblin = preload("res://Enemies/Goblin.tscn")
const Wall = preload("res://World/Wall.tscn")

onready var scheduler = $Scheduler
onready var tilemap = $TileMap
var astar

func _ready() -> void:
	# randomize() # TODO enable
	turn_tilemap_into_scenes()
	scheduler.init_actors()	
	scheduler.start_game()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print('mouse pressed')
		update()

func _draw():

	var BASE_LINE_WIDTH = 3.0

	var enemies = get_tree().get_nodes_in_group("enemies")
	astar = enemies[0].astar

	if not astar:
		return
	for point in astar.get_points():
		var neighbors = astar.get_point_connections(point)
		var pos = Grid.to_world_vec(astar.get_point_position(point))
		if astar.is_point_disabled(point):
			draw_circle(pos, BASE_LINE_WIDTH * 2.0, Color.red)
		else:
			draw_circle(pos, BASE_LINE_WIDTH * 2.0, Color.blue)
			
		for neighbor in neighbors:
			var target_pos = Grid.to_world_vec(astar.get_point_position(neighbor))
			
			draw_line(pos, target_pos, Color.blue, BASE_LINE_WIDTH, true)

	draw_circle(enemies[0].global_position, BASE_LINE_WIDTH * 2.0, Color.green)
	draw_circle(Grid.to_world_vec(Vector2(5,5)), BASE_LINE_WIDTH * 2.0, Color.green)
	
	var goblin_coords = enemies[0].get_board_coord()
	var path = astar.get_point_path(Board.get_id(goblin_coords.x, goblin_coords.y), Board.get_id(5, 5))
	var path_in_world_coords = Fp.map(path, funcref(Grid, "to_world_vec"))
	draw_polyline(path_in_world_coords, Color.red, 18.0)
	
func turn_tilemap_into_scenes() -> void:
	for pos in tilemap.get_used_cells():
		var tile_id = tilemap.get_cellv(pos)
		match tile_id:
			0: 
				turn_tile_into_scene(pos, Wall)
			1: 
				turn_tile_into_scene(pos, Goblin)
			2: # dwarf
				turn_tile_into_scene(pos, Dwarf)

func turn_tile_into_scene(pos: Vector2, Scene: PackedScene) -> void:
	var instance = Scene.instance()
	add_child(instance)
	instance.global_position = tilemap.map_to_world(pos) * tilemap.scale
	instance.add_to_board()
	tilemap.set_cellv(pos, -1) # clears the cell

