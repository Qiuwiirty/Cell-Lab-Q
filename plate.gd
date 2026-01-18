extends Node2D
class_name Plate

var mode = Game.ToolSelector.CELL_SYNTHESIZER
var photocyte = preload("res://Cells/Tscn file/photocyte.tscn")
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			match mode:
				Game.ToolSelector.CELL_SYNTHESIZER:
					var new_cell = photocyte.instantiate()
					new_cell.global_position = get_global_mouse_position() + Vector2(randf(), randf())
					add_child(new_cell)
					$PlaceCell.play()
				Game.ToolSelector.OPTICAL_TWEEZERS:
					pass
				Game.ToolSelector.CELL_BOOST:
					pass
				Game.ToolSelector.CELL_REMOVAL:
					pass
				Game.ToolSelector.CELL_DIAGNOSTICS:
					pass
func _ready() -> void:
	correct_brightness_plate()
func correct_brightness_plate():
	$Platecolor.material.set_shader_parameter("brightness", Game.brightness_mult)
func sterilize():
	for object in get_children():
		if object is BaseCell:
			object.queue_free()
func change_tool(into: Game.ToolSelector):
	mode = into
