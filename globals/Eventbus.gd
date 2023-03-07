extends Node

signal turn_ended

func emit_turn_ended() -> void:
	turn_ended.emit()
