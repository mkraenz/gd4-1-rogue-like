class_name Enemy
extends CharacterBody2D

signal acted

@onready var ray = $Ray
@onready var stats = $Stats
var dying := false
var attack_damage := 1
var speed := 10

var astar: AStar2D

func _ready():
	stats.connect("no_health", on_no_health)
	var astar = AStar2D.new()
	astar.add_point(1, Vector2(1, 0), 4) # Adds the point (1, 0) with weight_scale 4 and id 1

func act() -> void:
	if dying: return end_turn()

	if not astar:
		astar = Grid.get_astar(self)

	var direction = Vector2.LEFT

	ray.target_position = direction * Grid.STEP_SIZE
	ray.force_raycast_update()
	if ray.is_colliding():
		var target = ray.get_collider()
		if target is Player:
			var attack_tween := attack(direction, target)
			await attack_tween.finished
		return end_turn()

	position += direction * Grid.STEP_SIZE
	return end_turn()

func end_turn() -> void:
	acted.emit()

func take_damage(damage: int) -> void:
	stats.health -= damage

func attack(direction: Vector2, target: Node) -> Tween:
	var tween = create_tween()
	var original_position := position
	tween.tween_property(self, 'position', direction * Grid.STEP_SIZE / 2, 1.0 / speed).as_relative().set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	tween.tween_property(self, 'position', original_position, 1.0 / speed)
	target.take_damage(attack_damage)
	return tween

func on_no_health() -> void:
	dying = true
	var tween = create_tween()
	tween.tween_property(self, 'modulate:a', 0, 0.3)
	await tween.finished
	queue_free()
