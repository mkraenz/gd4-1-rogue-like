extends Node

# for each cell (x,y), this is an Array of all entities that exist on that cell
var grid := {}

# 1-based (like array.length)
var width := 0
# 1-based (like array.length)
var height := 0

func _ready() -> void:
	init(11, 6)

# initializes the grid with width-many cells in x-direction and height-many cells in y-direction (zero-based)
func init(_width: int, _height: int) -> void:
	width = _width
	height = _height
	for x in range(width):
		for y in range(height):
			grid[Vector2(x,y)] = []

func add(cell: Vector2, entity: CollisionObject2D) -> void:
	grid[cell].append(entity)

func add_from_world(global_position: Vector2, entity: CollisionObject2D) -> void:
	var cell = Grid.to_board_vec(global_position)
	grid[cell].append(entity)

func move(from: Vector2, to: Vector2, entity: CollisionObject2D) -> void:
	assert(grid[from].has(entity), entity.name + " does not exist on cell " + str(from))
	grid[from].erase(entity)
	grid[to].append(entity)

func can_move(from: Vector2, to: Vector2, entity: CollisionObject2D) -> bool:
	assert(grid[from].has(entity), entity.name + " does not exist on cell " + str(from))
	if is_out_of_bounds(to):
		return false

	update_cell(to)
		
	return not is_colliding(to, entity)

func is_colliding(at: Vector2, entity: CollisionObject2D) -> bool:
	update_cell(at)
	for entity_at_target_cell in grid[at]:
		# don't collide with yourself
		if entity_at_target_cell == entity:
			return false
		var colliding = entity.collision_mask & entity_at_target_cell.collision_layer
		if colliding:
			return true
	return false

func update_cell(at: Vector2) -> void:
	grid[at] = Fp.filter_existent(grid[at])

func get_colliders(at: Vector2, entity: CollisionObject2D) -> Array:
	update_cell(at)

	var colliders = []
	for entity_at_target_cell in grid[at]:
		var entity_is_colliding = entity.collision_mask & entity_at_target_cell.collision_layer
		if entity_is_colliding:
			colliders.append(entity_at_target_cell)
	return colliders

func get_hit_colliders(at: Vector2, entity: CollisionObject2D) -> Array:
	update_cell(at)

	var colliders = []
	if not entity.has_node("HitDetector"):
		prints(entity.name, 'does not have a HitDetector node')
		return colliders
	var hit_detector = entity.get_node("HitDetector")
	for entity_at_target_cell in grid[at]:
		if entity_at_target_cell.has_node("Hurtbox"):
			var hurtbox = entity_at_target_cell.get_node("Hurtbox")
			var is_hit = hit_detector.collision_mask & hurtbox.collision_layer
			if is_hit:
				colliders.append(entity_at_target_cell)
		else:
			prints(entity_at_target_cell.name, 'does not have a Hurtbox node')
	return colliders


func reset() -> void:
	pass # TODO implement

func is_out_of_bounds(cell: Vector2) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x > width -1 or cell.y > height - 1 

# idea: since this depends not on the entity but on the PackedScene of the entity (i.e. is it a Goblin, or a Dwarf), we only need #PackedScenes many astar instances
# TODO: oh man... maybe it's better to use the board cells as astar vertices and then multiply by the size of the entity to get the global position of the entity
func get_astar(entity: CollisionObject2D) -> AStar2D:
	var astar = AStar2D.new()

	var impassable := get_tree().get_nodes_in_group("impassables")
	var impassable_ids = Fp.map(impassable, func(x): return get_id_from_global_position(x))

	# generate points
	for x in range(width):
		for y in range(height):
			if impassable_ids.has(get_id(x,y)):
				continue
			astar.add_point(width * y + x, Vector2(x, y))

	
	# connect points
	for x in range(width):
		for y in range(height):
			var id = get_id(x,y)
			if not astar.has_point(id):
				continue

			var connect_if_point_exists = func(other_id):
				if astar.has_point(other_id):
					astar.connect_points(id, other_id)
		
			if x == width - 1:
				# connect to down neighbors
				if y == height -1:
					continue
				connect_if_point_exists.call(x+ width * (y+1))
			elif y == height -1:
				connect_if_point_exists.call((x+1) + width * y)
			else:
				# connect to right neighbors
				connect_if_point_exists.call((x+1) + width * y)
				# connect to down neighbors
				connect_if_point_exists.call(x + width * (y+1))
	update_disabled_astar_points(astar, entity)
	return astar

func update_disabled_astar_points(astar: AStar2D, entity: Node2D) -> void:
	# disable where entity would collide with something (e.g. another enemy) (impassables like walls are already disabled)
	for x in range(width):
		for y in range(height):
			if astar.has_point(get_id(x,y)):
				var disabled = is_colliding(Vector2(x,y), entity)
				astar.set_point_disabled(get_id(x,y), false)
				astar.set_point_disabled(get_id(x,y), disabled)

func get_id(x: int, y: int) -> int:
	return x + width * y

func get_id_from_vec(vec: Vector2) -> int:
	return get_id(int(vec.x), int(vec.y))

func get_id_from_global_position(entity: Node2D) -> int:
	var board_vec = Grid.to_board_vec(entity.global_position)
	return get_id_from_vec(board_vec)
	
