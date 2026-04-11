extends Node2D

func _draw() -> void:
	if Game.show_food_spawn_marker:
		#I might add another shape, but for now only 2
		match Game.food_spawn_shape:
			Food.SpawnShape.RECTANGLE:
				draw_rect(Rect2(-Game.rect_spawn_size / 2, Game.rect_spawn_size), Color.WHITE, false)
			Food.SpawnShape.CIRCLE:
				draw_circle(Vector2.ZERO, Game.radii_spawn_size, Color.WHITE, false)
			_:
				print("Unindentified food spawn shape!: ", Game.food_spawn_shape)
