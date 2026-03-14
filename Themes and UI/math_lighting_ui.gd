extends HBoxContainer
func _ready() -> void:
	$x.value = Game.math_lighting.x
	$y.value = Game.math_lighting.y
	$z.value = Game.math_lighting.z
	$w.value = Game.math_lighting.w
func _on_x_value_changed(value: float) -> void:
	Game.math_lighting.x = value

func _on_y_value_changed(value: float) -> void:
	Game.math_lighting.y = value

func _on_z_value_changed(value: float) -> void:
	Game.math_lighting.z = value

func _on_w_value_changed(value: float) -> void:
	Game.math_lighting.w = value
