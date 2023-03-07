class_name Player
extends CharacterBody2D

signal has_died(this: Node2D)

const action_exhausting_inputs := ["left", "right", "up", "down", "wait"]

@onready var hit_detector := $HitDetector
@onready var stats := $Stats
@onready var input_cooldown := $InputCooldown

func add_to_board() -> void:
	Board.add_from_world(global_position, self)

func _ready() -> void:
	_wait_for_other_entities_turn(true)
	var _a = stats.connect("no_health", _on_no_health)
	add_to_board()

func act() -> void:
	_wait_for_other_entities_turn(false)

func _is_action_input(event: InputEvent) -> bool:
	for action in action_exhausting_inputs:
		if event.is_action_pressed(action):
			return true 
	return false

func _unhandled_key_input(event: InputEvent) -> void:
	if not input_cooldown.is_stopped():
		return # avoid that we receive many events from essentially a single button press

	if not _is_action_input(event):
		# since unhandled input triggers for any key press and even mouse movements, we need to ensure we only handle actual ingame actions
		return

	input_cooldown.start()
	
	var input_vec = Input.get_vector("left", "right", "up", "down")
	# Since this algo does not quite work if input_vec is not a cardinal direction, we just limit it to the cardinals
	if input_vec in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
		var oned_input_vec = Vector2(round(input_vec.x), round(input_vec.y))

		var from = Grid.to_board_vec(global_position)
		var to = from + oned_input_vec

		if Board.can_move(from, to, self):
			# move
			move(from, to)
		else:
			# attack if possible
			var next_cell_rel = Grid.to_world_vec(oned_input_vec)
			var colliders = hit_detector.get_colliders(next_cell_rel)
			for collider in colliders:
				attack(collider)

	_wait_for_other_entities_turn(true)
	Eventbus.emit_turn_ended()
	
func move(from: Vector2, to: Vector2) -> void:
	Board.move(from, to, self)
	global_position = Grid.to_world_vec(to)

func _wait_for_other_entities_turn(is_waiting: bool) -> void:
	set_process_unhandled_key_input(not is_waiting)

func attack(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(1.0)
	else:
		prints("WARNING:", target.name, "does not implement the take_damage(dmg) method!")

func take_damage(damage: float) -> void:
	print('player got hit')
	stats.health -= damage
	has_died.emit(self)

func _on_no_health() -> void:
	queue_free()
	
