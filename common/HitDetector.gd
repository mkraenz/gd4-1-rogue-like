extends RayCast2D


# @example 1:
# `hit_detector.get_colliders(player.global_position - right_cell.global_position)`
# to try to attack something to the right of the player.
# @example 2:
# `hit_detector.get_colliders((player.global_position - right_cell.global_position) * 2)`
# to try to attack the cell right of the player AND the cell behind it.
func get_colliders(to: Vector2) -> Array:
    var colliders = []
    target_position = to
    force_raycast_update() # initial update is important to make it work _this_ physics frame

    # rays do not provide a method to get _all_ colliders, thus we write the code for it ourselves
    while is_colliding():
        var collider = get_collider()
        colliders.append(collider) 
        add_exception(collider) #add to ray's exception. That way it could detect something being behind it.
        force_raycast_update() #update the ray's collision query.
    colliders = Fp.filter(colliders, func(x: Node) -> bool: return is_instance_valid(x)) 
    clear_exceptions()
    return colliders
