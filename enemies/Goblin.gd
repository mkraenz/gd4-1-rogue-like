extends CharacterBody2D

@onready var stats := $Stats
@onready var hit_detector := $HitDetector
@onready var player_detector := $PlayerDetector
var _player: Player = null

var path = []
var astar: AStar2D

func _ready() -> void:
	stats.connect("no_health", _on_Stats_no_health)
	player_detector.connect("player_detected", _on_PlayerDetector_player_detected)
	player_detector.connect("player_lost", _on_PlayerDetector_player_lost)
	add_to_board()

func _on_PlayerDetector_player_detected(player: Player) -> void:
	_player = player

func _on_PlayerDetector_player_lost() -> void:
	_player = null

func add_to_board() -> void:
	Board.add_from_world(global_position, self)

func act() -> void:
	print('goblin acts')
	if not astar:
		astar = Board.get_astar(self)

	if _player:
		var coords = Grid.to_board_vec(global_position)
		var id = Board.get_id(coords.x, coords.y)
		var player_coords = _player.get_board_coord()
		var target_id = Board.get_id(player_coords.x,player_coords.y)

		path = astar.get_point_path(id, target_id)
		var from = Grid.to_board_vec(global_position)
		var to = path[1]

		var colliders = Board.get_hit_colliders(to, self)
		print("colliders", colliders)
		if len(colliders) > 0:
			for collider in colliders:
				attack(collider)
		elif Board.can_move(from, to, self):
			move(from, to)

	Eventbus.emit_turn_ended()

func update_hit_detector(target_cell: Vector2) -> void:
	hit_detector.target_position = Grid.to_world_vec(target_cell) - global_position
	hit_detector.force_raycast_update()

func move(from: Vector2, to: Vector2) -> void:
	Board.move(from, to, self)
	global_position = Grid.to_world_vec(to)	

func take_damage(damage: float) -> void:
	stats.health -= damage
	prints("goblin got hit for ", damage, "new health", stats.health)

func attack(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(1.0)
	
func _on_Stats_no_health() -> void:
	print('goblin died')
	Eventbus.emit_entity_died(self)
	queue_free()

func get_board_coord() -> Vector2:
	return Grid.to_board_vec(global_position)
