extends PanelContainer
class_name CellStateDependence
signal closed
var _dragging := false
var _drag_offset := Vector2.ZERO
const ANIM_DURATION = 0.1

var genome_param: GenomeParam

const cell_state_dependence = preload("uid://b0ispw50j2u21")
const spinbox_container_UI = preload("uid://cpdpub4j2wjp2")
const button_container_UI = preload("uid://bolfe4x3lnmsl")

func _ready() -> void:
	for i in GenomeParam.Mode.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.add_item(GenomeParam.Mode.keys()[i], i)
	for i in GenomeParam.CellInput.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/input/OptionButton.add_item(GenomeParam.CellInput.keys()[i], i)
	for i in GenomeParam.Formula.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/value/OptionButton.add_item(GenomeParam.Formula.keys()[i], i)
func open():
	show()
	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	#set_trans and set_ease are added to make it more smooth
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2.ONE, ANIM_DURATION)

	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
	
	move_to_front()
func close():
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), ANIM_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION)
	tween.set_parallel(false)
	tween.tween_callback(func(): hide(); emit_signal("closed"))
func assign_genome_param(gp: GenomeParam) -> void:
	genome_param = gp
	$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.selected = genome_param.mode
	update_values()
	open()
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func _on_mode_selected(index: int) -> void:
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state.hide()
	genome_param.mode = index as GenomeParam.Mode
	print("A")
	match genome_param.mode:
		GenomeParam.Mode.FIXED:
			$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value.show()
		GenomeParam.Mode.USE_STATE:
			$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state.show()
#region fixed value 
#FLOAT!
func _on_fixed_value_changed(value: float) -> void:
	if genome_param.fixed_value is int:
		genome_param.fixed_value = int(value)
	else:
		genome_param.fixed_value = value
func _on_fixed_value_bool_toggled(toggled_on: bool) -> void:
	genome_param.fixed_value = toggled_on

func _on_fixed_value_item_selected(index: int) -> void:
	genome_param.fixed_value = index

func create_fixed_value_array() -> void:
	for child in $VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.get_children(): child.queue_free()
	if genome_param.fixed_value is not Array: print("fixed value is not array"); return
	if genome_param.fixed_value.is_empty(): print("array is empty"); return
	var i = 0
	for value in genome_param.fixed_value:
		if value is GenomeParam:
			var new_genome_param_UI = button_container_UI.instantiate()
			new_genome_param_UI.get_node("Label").text = "Property " + str(i)
			new_genome_param_UI.get_node("Button").text = "Edit.."
			new_genome_param_UI.get_node("Button").button_up.connect(another_genome_param_edit_button_up.bind(value))
			$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.add_child(new_genome_param_UI)
		elif value is bool:
			var new_checkbox_UI = CheckBox.new()
			new_checkbox_UI.text = "Bool " + str(i)
			new_checkbox_UI.toggled.connect(array_bool_toggled.bind(i))
			$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.add_child(new_checkbox_UI)
		elif value is float:
			var new_spinbox_container_UI = spinbox_container_UI.instantiate()
			new_spinbox_container_UI.get_node("Label").text = "Value " + str(i)
			new_spinbox_container_UI.get_node("SpinBox").value = value
			new_spinbox_container_UI.get_node("SpinBox").value_changed.connect(array_spinbox_value_edited.bind(i))
			$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.add_child(new_spinbox_container_UI)
		elif value is int:
			var new_spinbox_container_UI = spinbox_container_UI.instantiate()
			new_spinbox_container_UI.get_node("Label").text = "Value " + str(i)
			new_spinbox_container_UI.get_node("SpinBox").value = value
			new_spinbox_container_UI.get_node("SpinBox").step = 1.0
			new_spinbox_container_UI.get_node("SpinBox").value_changed.connect(array_spinbox_value_edited.bind(i))
			$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.add_child(new_spinbox_container_UI)
		i += 1
func another_genome_param_edit_button_up(another_genome_param: GenomeParam) -> void:
	var new_cell_state_dependence = cell_state_dependence.instantiate()
	Game.UI.add_child(new_cell_state_dependence) 
	new_cell_state_dependence.assign_genome_param(another_genome_param)
	new_cell_state_dependence.closed.connect(func(): new_cell_state_dependence.queue_free())
func array_spinbox_value_edited(value: float, index: int) -> void:
	if genome_param.fixed_value[index] is float:
		genome_param.fixed_value[index] = value
	elif genome_param.fixed_value[index] is int:
		genome_param.fixed_value[index] = int(value)
func array_bool_toggled(toggled_on: bool, index: int) -> void:
	genome_param.fixed_value[index] = toggled_on
#endregion fixed_value
func _on_input_selected(index: int) -> void:
	genome_param.input = index as GenomeParam.CellInput

func _on_input_signal_value_changed(value: float) -> void:
	genome_param.input_signal = int(value)

func _on_value_formula_selected(index: int) -> void:
	genome_param.formula = index as GenomeParam.Formula

func _on_a_value_changed(value: float) -> void:
	genome_param.a = value

func _on_b_value_changed(value: float) -> void:
	genome_param.b = value

func _on_c_value_changed(value: float) -> void:
	genome_param.c = value
func update_values() -> void:
	if genome_param.force_fixed_value:
		genome_param.mode = GenomeParam.Mode.FIXED
		$VBoxContainer/ScrollContainer/VBoxContainer/warning.show()
		$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.disabled = true
	else:
		$VBoxContainer/ScrollContainer/VBoxContainer/warning.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.disabled = false
	
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_bool.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_options.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state.hide()
	
	match genome_param.mode:
		GenomeParam.Mode.FIXED:
			if genome_param.fixed_value is bool:
				$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_bool.show()
			elif genome_param.fixed_value is int:
				if genome_param.enum_info:
					$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_options.show()
					var option_button = $VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_options/OptionButton
					option_button.clear()
					for key in genome_param.enum_info:
						option_button.add_item(key, genome_param.enum_info[key])
					option_button.selected = option_button.get_item_index(genome_param.fixed_value)
				else:
					$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value.show()
			elif genome_param.fixed_value is float:
				$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value.show()
			elif genome_param.fixed_value is Array:
				$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value_array.show()
				create_fixed_value_array()
		GenomeParam.Mode.USE_STATE:
			$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state.show()
	
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.max_value = 1000.0
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.min_value = -1000.0
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 0.001
	if genome_param.fixed_value is bool:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.max_value = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.min_value = 0.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = 1.0 if genome_param.fixed_value else 0.0
	elif genome_param.fixed_value is int and not genome_param.enum_info:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = float(genome_param.fixed_value)
	elif genome_param.fixed_value is float:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = genome_param.fixed_value
	
	#sync values
	$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.selected = genome_param.mode
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/input/OptionButton.selected = genome_param.input
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/input_signal/SpinBox.value = genome_param.input_signal
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/value/OptionButton.selected = genome_param.formula
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/a/SpinBox.value = genome_param.a
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/b/SpinBox.value = genome_param.b
	$VBoxContainer/ScrollContainer/VBoxContainer/use_cell_state/c/SpinBox.value = genome_param.c
