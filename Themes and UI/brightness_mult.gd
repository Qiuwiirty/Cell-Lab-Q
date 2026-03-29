extends HBoxContainer

func _on_b_value_changed(value: float) -> void:
	Game.brightness_mult = value
