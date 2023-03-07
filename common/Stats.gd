extends Node

signal health_changed(new_val)
signal max_health_changed(new_val)
signal no_health

var max_health: int = 3:
	get:
		return max_health
	set(value):
		max_health = max(value, 1)
		max_health_changed.emit(max_health)

var health: int = 3:
	get:
		return health
	set(value):
		health = min(max(value, 0), max_health)
		health_changed.emit(health)
		if health <= 0:
			no_health.emit()
