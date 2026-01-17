extends Node2D
var photocyte = preload("res://Cells/Tscn file/photocyte.tscn")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and event.pressed:
			var new_cell = photocyte.instantiate()
			new_cell.global_position = get_global_mouse_position() + Vector2(randf(), randf())
			add_child(new_cell)
			$PlaceCell.play()
func _ready() -> void:
	correct_brightness_plate()
func correct_brightness_plate():
	$Platecolor.material.set_shader_parameter("brightness", Game.brightness_mult)
