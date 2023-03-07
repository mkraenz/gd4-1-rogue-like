extends Node

var _actors: Array = []
var _current = 0

func add(actor: Node):
	assert(actor.has_method("act"))
	assert(actor.has_method("end_turn"))
	actor.connect('acted', on_end_turn)
	_actors.append(actor)

func get_current():
	return _actors[_current]

func goto_next():
	_current = (_current + 1) % len(_actors)
	if not is_instance_valid(_actors[_current]):
		goto_next()

func on_end_turn():
	goto_next()
	get_current().act()
