class_name Player
extends CharacterBody2D

signal acted

@onready var ray = $Ray
@onready var stats= $Stats

var speed := 10
var attack_damage := 1

func _ready():
	stats.connect("no_health", on_no_health)

func _unhandled_key_input(_event):
	var vec := Input.get_vector("left", "right", "up", "down")
	if vec != Vector2.ZERO:
		set_process_unhandled_key_input(false) # make sure to stop the correct input handler
		var direction = vec.normalized()
		ray.target_position = direction * Grid.STEP_SIZE 
		ray.force_raycast_update()
		if ray.is_colliding():
			print("colliding with: ", ray.get_collider())
			var target = ray.get_collider()
			if target is Enemy:
				var attack_tween := attack(direction, target)
				await attack_tween.finished
				end_turn()
				return
			end_turn()
			return

		var moveTween := move(direction)
		await moveTween.finished
		end_turn()
		# end turn called by move

func move(direction: Vector2) -> Tween:
	print('moving')

	# position += direction * Grid.STEP_SIZE
	var tween = create_tween()
	tween.tween_property(self, "position",
		direction * Grid.STEP_SIZE, 1.0 / speed).as_relative().set_trans(Tween.TRANS_SINE)
	return tween

func attack(direction: Vector2, target: Enemy) -> Tween:
	var tween = create_tween()
	var original_position := position
	tween.tween_property(self, 'position', direction * Grid.STEP_SIZE / 2, 1.0 / speed).as_relative().set_trans(Tween.TRANS_CUBIC).set_delay(0.1)
	tween.tween_property(self, 'position', original_position, 1.0 / speed)
	target.take_damage(attack_damage)
	return tween

func act() -> void:
	set_process_unhandled_key_input(true)

func end_turn() -> void:
	acted.emit()

func take_damage(damage: int) -> void:
	stats.health -= damage

func on_no_health() -> void:
	print('Game Over. Player is dead.')
	queue_free()
