extends Node2D
class_name Plate

var mode = Game.ToolSelector.CELL_SYNTHESIZER
const photocyte = preload("uid://sy8jnyx6hyux")
const food = preload("uid://bcp4xdxc828fp")

var selected_cell = null
var locked_to_selected = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			match mode:
				Game.ToolSelector.CELL_SYNTHESIZER:
					var new_cell = photocyte.instantiate()
					#Add by Vector2(randf(), randf()) to avoid weird physics issue
					new_cell.global_position = get_global_mouse_position() + Vector2(randf(), randf())
					add_child(new_cell)
					$PlaceCell.play()
				Game.ToolSelector.OPTICAL_TWEEZERS:
					pass
				Game.ToolSelector.CELL_BOOST:
					var new_food = food.instantiate()
					new_food.global_position = get_global_mouse_position() + Vector2(randf(), randf())
					add_child(new_food)
					$PlaceCell.play()
				Game.ToolSelector.CELL_REMOVAL:
					pass
				Game.ToolSelector.CELL_DIAGNOSTICS:
					if selected_cell:
						selected_cell.to_select(false)
						selected_cell = null
						locked_to_selected = false
					else:
						$Invalid.play()
func _process(delta: float) -> void:
	if selected_cell and locked_to_selected:
		$Camera2D.global_position = selected_cell.global_position
func _ready() -> void:
	correct_brightness_plate()
func correct_brightness_plate():
	$Platecolor.material.set_shader_parameter("brightness", Game.brightness_mult)
func sterilize():
	get_tree().call_group("cells", "queue_free")
	get_tree().call_group("food", "queue_free")
func change_tool(into: Game.ToolSelector):
	mode = into
func change_substrate_temperature(into: Game.SubstrateTemperature):
	Game.temperature = into
	match into:
		Game.SubstrateTemperature.FREEZE:
			pass
		Game.SubstrateTemperature.SLOW_OBSERVE:
			pass
		Game.SubstrateTemperature.OBSERVE:
			pass
		Game.SubstrateTemperature.INCUBATE:
			pass
func tween_to_selected_cell_position() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D, "global_position", selected_cell.global_position, 0.5)
	tween.tween_callback(func(): locked_to_selected = true)
	
