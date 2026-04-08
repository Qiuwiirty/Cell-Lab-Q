extends PanelContainer
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1

var _dragging := false
var _drag_offset := Vector2.ZERO

var cell: BaseCell
var mode: CellMode
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

func _process(_delta: float) -> void:
	if !cell:
		return
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

func _on_spin_box_value_changed(value: float) -> void:
	if cell:
		if cell.dna:
			mode = cell.dna.modes[value]
			update_DNA_values()

func _on_disable_metabolism_toggled(toggled_on: bool) -> void:
	if mode:
		mode.disable_metabolism = toggled_on

func _on_cell_type_selected(index: int) -> void:
	if mode:
		mode.cell_type = index as Game.CellType
		cell.turn_into_another_cell_type(index)

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
		$VBoxContainer/ScrollContainer/VBoxContainer/split_ratio/SpinBox.value = cell.mode.split_ratio
		$VBoxContainer/ScrollContainer/VBoxContainer/split_angle/SpinBox.value = cell.mode.split_angle
		$VBoxContainer/ScrollContainer/VBoxContainer/child1/SpinBox.value = cell.mode.child1
		$VBoxContainer/ScrollContainer/VBoxContainer/child2/SpinBox.value = cell.mode.child2
		$VBoxContainer/ScrollContainer/VBoxContainer/make_adhesion.button_pressed = cell.mode.make_adhesion
		$VBoxContainer/ScrollContainer/VBoxContainer/adhesion_stiffness/SpinBox.value = cell.mode.adhesion_stiffness
		$VBoxContainer/ScrollContainer/VBoxContainer/flow_rate/SpinBox.value = cell.mode.flow_rate
