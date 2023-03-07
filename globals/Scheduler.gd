extends Node

@onready var eventbus = Eventbus

# each actor needs to implement an `act() -> void` function that emits an `eventbus.emit_turn_ended()` signal
var _actors: Array[Node] = []
var _current_index := 0
var total_turn = 0

# Note: for whatever reason, using a getter does not work
func _current_actor():
	return _actors[_current_index]


func init_actors() -> void:
	var players = get_tree().get_nodes_in_group("player")
	var npcs = get_tree().get_nodes_in_group("friendly_npcs")
	var enemies = get_tree().get_nodes_in_group("enemies")
	_actors.append_array(players)
	_actors.append_array(npcs)
	_actors.append_array(enemies)
	Fp.foreach(_actors, func(actor: Node): return actor.connect("has_died", self._on_actor_has_died))
	prints("Actors initialized: ", len(_actors))

	eventbus.connect("turn_ended", end_turn)

func _on_actor_has_died(actor: Node) -> void:
	_actors.erase(actor)

func start_game() -> void:
	if _current_actor().has_method("act"):
		_current_actor().act()
	else:
		prints("WARNING: ", _current_actor().name, "does not have an act() method. Implement it!")
	end_turn() # from here on, actors will run sequentially

func end_turn() -> void:
	# prints(_current_actor().name, ": End turn.")
	_goto_next()
	print(_current_actor())
	# prints(_current_actor().name, ": Start turn.")
	_act()
	
func _act() -> void:
	# prints(_current_actor().name, ": checking for action.")
	var current_actor_is_alive = _current_actor() != null and is_instance_valid(_current_actor())
	# prints(_current_actor().name, ": is alive? ", current_actor_is_alive)
	if current_actor_is_alive:
		_current_actor().act()
	else:
		_actors.remove_at(_current_index)
		if _current_index > len(_actors) - 1:
			_current_index = 0
		_act()

func _goto_next() -> void:
	_current_index += 1
	total_turn += 1

	if _current_index > len(_actors) - 1:
		_current_index = 0
