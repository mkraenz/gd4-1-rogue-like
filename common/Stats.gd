extends Node

signal health_changed(data: Dictionary)
signal max_health_changed(data: Dictionary)
signal no_health

@export var max_health: int = 3:
	get:
		return max_health
	set(val):
		var is_unchanged = val == max_health
		if is_unchanged:
			return
		var prev = max_health
		max_health = max(val, 0)
		max_health_changed.emit({"diff": max_health - prev })

@export var health: int = 3:
	get:
		return health
	set(val):
		var is_unchanged = val == health
		if is_unchanged:
			return
		var prev = health
		health = min(val, max_health)
		health_changed.emit({"diff": health - prev})
		if health <= 0:
			emit_signal("no_health")
