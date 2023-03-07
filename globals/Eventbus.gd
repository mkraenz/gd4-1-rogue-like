extends Node

signal turn_ended
signal player_died
signal entity_died(entity: Node2D)

func emit_turn_ended() -> void:
	turn_ended.emit()

func emit_player_died() -> void:
	player_died.emit()

func emit_entity_died(entity: Node2D) -> void:
	entity_died.emit(entity)