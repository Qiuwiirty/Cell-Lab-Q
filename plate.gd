extends Node2D
class_name Plate

var mode = Game.ToolSelector.CELL_SYNTHESIZER
const photocyte = preload("uid://sy8jnyx6hyux") #I do not get why using preload and const cause an error in testplate if there basecell. 
const food = preload("uid://bcp4xdxc828fp")

var selected_cell: BaseCell = null
var locked_to_selected = false

var bind_adhesion_cell1: BaseCell = null
var bind_adhesion_cell2: BaseCell = null
func _unhandled_input(event: InputEvent) -> void:
	#ui_cancel is esc
	if event.is_action_pressed("ui_cancel"):
		discard_any_selection()
		Game.infonotice.hide()
	if event.is_action_pressed("ui_accept"):
		if bind_adhesion_cell1 and bind_adhesion_cell2:
			handle_adhesion_bind()
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
					$Invalid.play()
				Game.ToolSelector.CELL_DIAGNOSTICS:
					if selected_cell:
						selected_cell.to_select(false)
						selected_cell = null
						locked_to_selected = false
					else:
						$Invalid.play()
func _process(delta: float) -> void:
	if selected_cell:
		if Game.UI:
			Game.UI.set_diagnostics(selected_cell.diagnostics())
		if locked_to_selected:
			$Camera2D.global_position = selected_cell.global_position
	else:
		if Game.UI:
			#false make it not show any diagnostics
			Game.UI.set_diagnostics("false")
	if Game.use_math_lightning:
		$quad.material.set_shader_parameter("dir", Game.math_lighting)
func _ready() -> void:
	correct_brightness_plate()
func correct_brightness_plate():
	$Platecolor.material.set_shader_parameter("brightness", Game.brightness_mult)
func change_tool(into: Game.ToolSelector):
	mode = into
	if mode != Game.ToolSelector.CELL_DIAGNOSTICS or mode != Game.ToolSelector.BIND_ADHESION:
		discard_any_selection()
func discard_any_selection():
	discard_old_selected_cell()
	if bind_adhesion_cell1:
		bind_adhesion_cell1.discard_bind_selection()
		bind_adhesion_cell1 = null
		if bind_adhesion_cell2:
			bind_adhesion_cell2.discard_bind_selection()
			bind_adhesion_cell2 = null
#Move toward selected cell smoothly
func tween_to_selected_cell_position() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D, "global_position", selected_cell.global_position, 0.5)
	tween.tween_callback(func(): locked_to_selected = true)
#Remove selected cell
func discard_old_selected_cell() -> void:
	if selected_cell:
		#Second argument (play sound) is false because this function is often used when switching diagnostics. And switching diagnostics does not have the deselect so it is removed
		selected_cell.to_select(false, false)
		locked_to_selected = false
		selected_cell = null
func handle_adhesion_bind():
	#This assume if the cell's adhesion are symmetrical/mutual (IF NOT CAN CAUSE ISSUE)
	if not bind_adhesion_cell1.adhesion.has(bind_adhesion_cell2):
		if bind_adhesion_cell1.global_position.distance_to(bind_adhesion_cell2.global_position) < Game.max_adhesion_length:
			bind_adhesion_cell1.adhesion.append(bind_adhesion_cell2)
			bind_adhesion_cell2.adhesion.append(bind_adhesion_cell1)
			Game.infonotice.hide()
		else:
			Game.show_info_notice_timed("[color=red] [i] The distance between cells is too far for adhesion", 3)
	else:
		bind_adhesion_cell1.adhesion.erase(bind_adhesion_cell2)
		bind_adhesion_cell2.adhesion.erase(bind_adhesion_cell1)
		Game.infonotice.hide()
	discard_any_selection()
