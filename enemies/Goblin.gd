extends CharacterBody2D

signal has_died(this: Node2D)

@onready var stats := $Stats
@onready var hit_detector := $HitDetector

var path = []
var astar: AStar2D

func _ready() -> void:
	stats.connect("no_health", _on_Stats_no_health)
	add_to_board()

func add_to_board() -> void:
	Board.add_from_world(global_position, self)

func act() -> void:
	if not astar:
		astar = Board.get_astar(self)
    # for point in astar.get_points():
		# 	var sprite = Sprite.new()
		# 	sprite.texture = GodotLogo
		# 	sprite.scale = Vector2(0.2, 0.2)
		# 	get_tree().current_scene.add_child(sprite)
		# 	var pos = Grid.to_world_vec(astar.get_point_position(point))
		# 	sprite.global_position = pos



	var coords = Grid.to_board_vec(global_position)
	var id = Board.get_id(coords.x, coords.y)
	var target_id = Board.get_id(5, 5)

	path = astar.get_point_path(id, target_id)
	# if not path:
	# 	if astar.are_points_connected(id, target_id):

	# 		print("points are connected")
	# 		printt('current', id, astar.get_point_position(id), 'target',target_id, astar.get_point_position(target_id))
	# 		print(path)
	# 		print(astar.get_point_path(id, target_id))
	# 	else:
	# 		print("points are not connected")
	var dir = Math.random_unit_step()
	var from = Grid.to_board_vec(global_position)
	var to = Vector2(1,1) # path[-1]

	if Board.can_move(from, to, self):
		pass
		# Board.move(from, to, self)
		# global_position = Grid.to_world_vec(to)
	else:
		var next_cell_rel = Grid.to_world_vec(dir)
		var colliders = hit_detector.get_colliders(next_cell_rel)
		for collider in colliders:
			attack(collider)

	Eventbus.emit_turn_ended()

func take_damage(damage: float) -> void:
	stats.health -= damage
	prints("goblin got hit for ", damage, "new health", stats.health)

func attack(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(1.0)
	
func _on_Stats_no_health() -> void:
	has_died.emit(self)
	queue_free()

func get_board_coord() -> Vector2:
	return Grid.to_board_vec(global_position)
