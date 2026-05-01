extends PanelContainer
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1

var _dragging := false
var _drag_offset := Vector2.ZERO

var zone: Zone
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
	tween.tween_callback(hide)
	zone = null

func assign_zone(new_zone: Zone):
	$VBoxContainer/ScrollContainer/VBoxContainer/color_of_zone/ColorPickerButton.color = new_zone.modulate
	$VBoxContainer/ScrollContainer/VBoxContainer/Size/x.value = new_zone.scale.x
	$VBoxContainer/ScrollContainer/VBoxContainer/Size/y.value = new_zone.scale.y
	$VBoxContainer/ScrollContainer/VBoxContainer/salinity/SpinBox.value = new_zone.salinity
	$VBoxContainer/ScrollContainer/VBoxContainer/nitrates/SpinBox.value = new_zone.nitrates
	$VBoxContainer/ScrollContainer/VBoxContainer/max_adhesion_length/SpinBox.value = new_zone.max_adhesion_length
	$VBoxContainer/ScrollContainer/VBoxContainer/brightness_mult/SpinBox.value = new_zone.brightness_mult
	zone = new_zone

func delete_zone() -> void:
	zone.queue_free()
	zone = null
	close()

func _on_close_button_up() -> void:
	close()

func _ready() -> void:
	$are_you_sure_todelete.yes.button_up.connect(delete_zone)
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func _process(delta: float) -> void:
	if zone:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		zone.scale = (zone.scale + direction * delta * 5).max(Vector2(0., 0.))
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/x.value = zone.scale.x
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/y.value = zone.scale.y
func _on_color_zone_changed(color: Color) -> void:
	if zone:
		zone.modulate = Color(color.r, color.g, color.b, 0.3906)
		zone.update_conf()

func _on_x_size_changed(value: float) -> void:
	if zone:
		zone.scale.x = value
		zone.update_conf()

func _on_y_size_changed(value: float) -> void:
	if zone:
		zone.scale.y = value
		zone.update_conf()


func _on_salinity_changed(value: float) -> void:
	if zone:
		zone.salinity = value
		zone.update_conf()

func _on_nitrates_changed(value: float) -> void:
	if zone:
		zone.nitrates = value
		zone.update_conf()

func _on_max_adhesion_length_changed(value: float) -> void:
	if zone:
		zone.max_adhesion_length = value
		zone.update_conf()

func _on_brightness_mult_changed(value: float) -> void:
	if zone:
		zone.brightness_mult = value
		zone.update_conf()

func _on_light_feed_cost_luminocyte_toggled(toggled_on: bool) -> void:
	if zone:
		zone.light_feed_cost_luminocyte = toggled_on
		zone.update_conf()

func _on_delete_button_up() -> void:
	$are_you_sure_todelete.open()


func _on_gravity_value_changed(value: float) -> void:
	if zone:
		zone.gravity_mult = value
		zone.update_conf()
