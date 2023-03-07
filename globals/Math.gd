class_name Math
extends Node


static func random_unit_vector2() -> Vector2:
    return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    
    # uniformly distributed vectors for 4 cardinal directions and Zero
static func random_unit_step() -> Vector2:
    var _unit_step_choices := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.ZERO]
    _unit_step_choices.shuffle()
    return _unit_step_choices[0]