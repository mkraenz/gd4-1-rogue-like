extends Node

const STEP_SIZE = 16

# for each cell (x,y), this is an Array of all entities that exist on that cell
var grid := {}

# 1-based (like array.length)
var width := 0
# 1-based (like array.length)
var height := 0

func _ready() -> void:
    init(20, 20)

# initializes the grid with width-many cells in x-direction and height-many cells in y-direction (zero-based)
func init(_width: int, _height: int) -> void:
    width = _width
    height = _height
    for x in range(width):
        for y in range(height):
            grid[Vector2(x,y)] = []

func get_id(x: int, y: int) -> int:
    return x + width * y
            

# idea: since this depends not on the entity but on the PackedScene of the entity (i.e. is it a Goblin, or a Dwarf), we only need #PackedScenes many astar instances
func get_astar(entity: CollisionObject2D) -> AStar2D:
    var astar = AStar2D.new()
    # generate points
    for x in range(width):
        for y in range(height):
            astar.add_point(width * y + x, Vector2(x, y))

    # connect points
    for x in range(width):
        for y in range(height):
            var id = get_id(x,y)
            if x == width - 1:
                # connect to down neighbors
                if y == height -1:
                    continue
                astar.connect_points(id, x + width * (y+1))
            elif y == height -1:
                # connect to right neighbors
                astar.connect_points(id, (x+1) + width * y)
            else:
                # connect to right neighbors
                astar.connect_points(id, (x+1) + width * y)
                # connect to down neighbors
                astar.connect_points(id, x + width * (y+1))

    # disable where entity would collide with something (e.g. enemy, wall)
    for x in range(width):
        for y in range(height):
            if is_colliding(Vector2(x,y), entity):
                astar.set_point_disabled(get_id(x,y))
    return astar


func is_colliding(at: Vector2, entity: CollisionObject2D) -> bool:
    for entity_at_target_cell in grid[at]:
        var colliding = entity.collision_mask & entity_at_target_cell.collision_layer
        if colliding:
            return true
    return false
    