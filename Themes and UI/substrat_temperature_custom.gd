extends PanelContainer
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###SUBSTRATE TEMPERATURE'S IMAGES: For setting image on TemperatureButton
const FREEZE = preload("uid://4f2i66tbqreo")
const SLOW_OBSERVE = preload("uid://p5fmju3af5d7")
const OBSERVE = preload("uid://6md56mn5ckjp")
const INCUBATE = preload("uid://dg2wqbvy11mos")
const CUSTOM = preload("uid://dslg8yitragtg") #AKA custom
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1

var _dragging := false
var _drag_offset := Vector2.ZERO

func _ready() -> void:
	$VBoxContainer/HSlider.value = 1.0
	
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

func _on_freeze_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = FREEZE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = FREEZE
	Game.temperature = Game.SubstrateTemperature.FREEZE
	$VBoxContainer/current_temperature.text = "Current temperature: Freeze"
	close()
	$"../ButtonClick2".play()
func _on_slow_observe_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = SLOW_OBSERVE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = SLOW_OBSERVE
	Game.temperature = Game.SubstrateTemperature.SLOW_OBSERVE
	$VBoxContainer/current_temperature.text = "Current temperature: Slow observe"
	close()
	$"../ButtonClick2".play()
func _on_observe_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = OBSERVE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = OBSERVE
	Game.temperature = Game.SubstrateTemperature.OBSERVE
	$VBoxContainer/current_temperature.text = "Current temperature: Observe"
	close()
	$"../ButtonClick2".play()
func _on_incubate_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = INCUBATE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = INCUBATE
	Game.temperature = Game.SubstrateTemperature.INCUBATE
	$VBoxContainer/current_temperature.text = "Current temperature: Incubate"
	close()
	$"../ButtonClick2".play()

func _on_custom_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = CUSTOM
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = CUSTOM
	Game.temperature = Game.SubstrateTemperature.CUSTOM
	$VBoxContainer/current_temperature.text = "Current temperature: Custom"

func _on_hslider_value_changed(value: float) -> void:
	Game.custom_temperature = value
	$VBoxContainer/custom_temperature_label.text = "Temperature Value: " + str(value)


func _on_close_button_up() -> void:
	close()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position

	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset
