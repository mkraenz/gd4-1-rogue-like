extends Area2D

signal got_hit(damage)

func _ready() -> void:
    if collision_layer == 0:
        prints("WARNING: Hurtbox's Collision layer is 0. This means that the object will not collide with anything. Hurtbox of", get_parent().name)

func take_damage(damage: int) -> void:
    get_parent().take_damage(damage)