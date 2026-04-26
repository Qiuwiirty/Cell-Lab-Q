extends PanelContainer
const spinbox_container_UI = preload("uid://cpdpub4j2wjp2")
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1
@onready var custProps = $VBoxContainer/ScrollContainer/VBoxContainer/custprops
@onready var signals = $VBoxContainer/ScrollContainer/VBoxContainer/signals
var _dragging := false
var _drag_offset := Vector2.ZERO

var cell: BaseCell
var mode: CellMode
func _ready() -> void:
	create_cell_type_items()
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

func close():
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), ANIM_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION)
	tween.set_parallel(false)
	tween.tween_callback(hide)
	if cell:
		cell.to_select(false)
		cell = null

func _on_close_button_up() -> void:
	close()

func _process(delta: float) -> void:
	if !cell:
		return

	var direction = Input.get_axis("ui_left", "ui_right")
	cell.rotation_degrees += direction * delta * 100
	#age:
	$VBoxContainer/ScrollContainer/VBoxContainer/Age.text = "Age: " + str(cell.age) + "h"
	#mass:
	$VBoxContainer/ScrollContainer/VBoxContainer/mass/realvalue.text = str(cell.mass) + " ng" 
	#radius:
	$VBoxContainer/ScrollContainer/VBoxContainer/radius/realvalue.text = str(cell.radius) + " μm"
	#energy loss coefficient:
	$VBoxContainer/ScrollContainer/VBoxContainer/energy_loss_coefficient/realvalue.text = str(cell.energy_loss_coefficient)
	#nitrogen reserve:
	$VBoxContainer/ScrollContainer/VBoxContainer/nitrogen_reserve/realvalue.text = str(cell.nitrogen_reserve)
	#current_color:
	$VBoxContainer/ScrollContainer/VBoxContainer/current_color/real_current_color.color = cell.current_color
	#signals:
	if signals.get_child_count() > 0:
		for i in range(cell.signals.size()):
			var realvalue = signals.get_child(i).get_node("realvalue")
			realvalue.text = str(snappedf(cell.signals[i], 0.0001))
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func _on_mass_changed(value: float) -> void:
	if cell:
		cell.mass = value

func _on_radius_changed(value: float) -> void:
	if cell:
		cell.radius = value

func _on_energy_loss_coefficient_changed(value: float) -> void:
	if cell:
		cell.energy_loss_coefficient = value

func _on_nitrogen_reserve_changed(value: float) -> void:
	if cell:
		cell.nitrogen_reserve = value

func _on_current_color_changed(color: Color) -> void:
	if cell:
		cell.current_color = color

func _on_mode_editing_changed(value: float) -> void:
	if cell:
		if cell.dna:
			mode = cell.dna.modes[value]
			update_DNA_values()

func _on_disable_metabolism_toggled(toggled_on: bool) -> void:
	if mode:
		mode.disable_metabolism = toggled_on

func _on_cell_type_selected(index: int) -> void:
	if mode:
		for other in get_tree().get_nodes_in_group("cells"):
			if other is BaseCell:
				if other.dna == cell.dna:
					if other.mode.id == mode.id:
						other.turn_into_another_cell_type(index)
		mode.cell_type = index as Game.CellType
func _on_color_changed(color: Color) -> void:
	if mode:
		mode.color = color

func _on_split_mass_changed(value: float) -> void:
	if mode:
		mode.split_mass = value

func _on_split_ratio_changed(value: float) -> void:
	#a:b . a is the antecedent, b is the consequent
	$VBoxContainer/ScrollContainer/VBoxContainer/split_ratio/consequent.text = ": " + str(100 - int(value))
	if mode:
		mode.split_ratio = value / 100. # / 100. cuz split_ratio is in 0. - 1.

func _on_split_angle_changed(value: float) -> void:
	if mode:
		mode.split_angle = int(value)

func _on_child1_changed(value: float) -> void:
	if mode:
		mode.child1 = int(value)

func _on_child2_changed(value: float) -> void:
	if mode:
		mode.child2 = int(value)

func _on_make_adhesion_toggled(toggled_on: bool) -> void:
	if mode:
		mode.make_adhesion = toggled_on

func _on_adhesion_stiffness_changed(value: float) -> void:
	if mode:
		mode.adhesion_stiffness = value

func assign_cell(new_cell: BaseCell) -> void:
	cell = new_cell
	mode = cell.dna.modes[cell.current_mode]
	
	update_DNA_values()

func _on_flow_rate_changed(value: float) -> void:
	if mode:
		mode.flow_rate = value

func update_DNA_values():
	if cell:
		$VBoxContainer/ScrollContainer/VBoxContainer/mode_editing/SpinBox.value = cell.current_mode
		$VBoxContainer/ScrollContainer/VBoxContainer/disable_metabolism.button_pressed = cell.mode.disable_metabolism
		$VBoxContainer/ScrollContainer/VBoxContainer/cell_type/OptionButton.selected = Game.get_cell_type(cell)
		$VBoxContainer/ScrollContainer/VBoxContainer/actual_color/ColorPickerButton.color = cell.mode.color
		$VBoxContainer/ScrollContainer/VBoxContainer/split_mass/SpinBox.value = cell.mode.split_mass
		$VBoxContainer/ScrollContainer/VBoxContainer/split_ratio/SpinBox.value = cell.mode.split_ratio * 100
		$VBoxContainer/ScrollContainer/VBoxContainer/split_angle/SpinBox.value = cell.mode.split_angle
		$VBoxContainer/ScrollContainer/VBoxContainer/child1/SpinBox.value = cell.mode.child1
		$VBoxContainer/ScrollContainer/VBoxContainer/child2/SpinBox.value = cell.mode.child2
		$VBoxContainer/ScrollContainer/VBoxContainer/make_adhesion.button_pressed = cell.mode.make_adhesion
		$VBoxContainer/ScrollContainer/VBoxContainer/adhesion_stiffness/SpinBox.value = cell.mode.adhesion_stiffness
		$VBoxContainer/ScrollContainer/VBoxContainer/flow_rate/SpinBox.value = cell.mode.flow_rate
		update_custprop()
		update_signals()
func update_custprop(): ###TODO: IMPLEMENT EDITING GENOME PARAM
	for child in custProps.get_children(): child.queue_free()
	if mode.custprop.size() > 0:
		var i = 0
		for value in mode.custprop:
			var new_spinbox_container_UI = spinbox_container_UI.instantiate()
			new_spinbox_container_UI.get_node("Label").text = cell.Props.keys()[i]
			new_spinbox_container_UI.get_node("SpinBox").value = value.fixed_value
			new_spinbox_container_UI.get_node("SpinBox").value_changed.connect(custprop_spinbox_value_changed.bind(i))
			custProps.add_child(new_spinbox_container_UI)
			i += 1
	else:
		var new_label = Label.new()
		new_label.text = "There's no custom properties to edit/view.."
		custProps.add_child(new_label)
func update_signals():
	for child in signals.get_children(): child.queue_free()
	if cell.signals.size() > 0:
		var i = 0
		for value: float in cell.signals:
			var new_spinbox_container_UI = spinbox_container_UI.instantiate()
			new_spinbox_container_UI.get_node("Label").text = "S" + str(i)
			new_spinbox_container_UI.get_node("SpinBox").value = 0.0
			new_spinbox_container_UI.get_node("SpinBox").value_changed.connect(signal_spinbox_value_changed.bind(i))
			var realvalue = Label.new()
			realvalue.name = "realvalue"
			realvalue.text = str(value)
			realvalue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			new_spinbox_container_UI.add_child(realvalue)
			signals.add_child(new_spinbox_container_UI)
			i += 1
	else:
		var new_label = Label.new()
		new_label.text = "There's no signals to edit/view.."
		custProps.add_child(new_label)
func custprop_spinbox_value_changed(value: float, index: int) -> void:
	mode.custprop[index].fixed_value = value

func signal_spinbox_value_changed(value: float, signaltype: int) -> void:
	cell.signals[signaltype] = value
func _on_make_dna_unique_button_up() -> void:
	cell.dna = cell.dna.duplicate()
	mode = cell.dna.modes[cell.current_mode]

func create_cell_type_items() -> void:
	var i = 0
	for cell_type in Game.CellType.keys():
		$VBoxContainer/ScrollContainer/VBoxContainer/cell_type/OptionButton.add_item(cell_type, i)
		i += 1
