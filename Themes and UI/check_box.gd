extends CheckBox

func _ready() -> void:
	button_pressed = Game.use_math_lightning
func _on_toggled(toggled_on: bool) -> void:
	Game.use_math_lightning = toggled_on
