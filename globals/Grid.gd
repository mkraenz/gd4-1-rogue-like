class_name Grid
extends Node

const step_x = 16
const step_y = 16

static func to_world_vec(pos: Vector2) -> Vector2:
	return Vector2(pos.x * step_x, pos.y * step_y)

static func to_board_vec(pos: Vector2) -> Vector2:
	var cell := Vector2(pos.x / step_x, pos.y / step_y)
	assert(floor(cell.x) == cell.x and floor(cell.y) == cell.y,
		'invalid cell. cells must be integer values. Found: {0}'.format([cell]))

	return cell
