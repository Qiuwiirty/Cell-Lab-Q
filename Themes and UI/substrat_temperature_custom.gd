extends PanelContainer
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###SUBSTRATE TEMPERATURE'S IMAGES: For setting image on TemperatureButton
const FREEZE = preload("uid://4f2i66tbqreo")
const SLOW_OBSERVE = preload("uid://p5fmju3af5d7")
const OBSERVE = preload("uid://6md56mn5ckjp")
const INCUBATE = preload("uid://dg2wqbvy11mos")
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1
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
	if plate is Plate:
		plate.change_substrate_temperature(Game.SubstrateTemperature.FREEZE)
	else:
		print("Plate is invalid and therefore unable to set substrate temperature")
	close()
	$"../ButtonClick2".play()
func _on_slow_observe_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = SLOW_OBSERVE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = SLOW_OBSERVE
	if plate is Plate:
		plate.change_substrate_temperature(Game.SubstrateTemperature.SLOW_OBSERVE)
	else:
		print("Plate is invalid and therefore unable to set substrate temperature")
	close()
	$"../ButtonClick2".play()
func _on_observe_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = OBSERVE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = OBSERVE
	if plate is Plate:
		plate.change_substrate_temperature(Game.SubstrateTemperature.OBSERVE)
	else:
		print("Plate is invalid and therefore unable to set substrate temperature")
	close()
	$"../ButtonClick2".play()
func _on_incubate_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = INCUBATE
	$"../TopPanel/Margin/Hbox/TemperatureButton".icon = INCUBATE
	if plate is Plate:
		plate.change_substrate_temperature(Game.SubstrateTemperature.INCUBATE)
	else:
		print("Plate is invalid and therefore unable to set substrate temperature")
	close()
	$"../ButtonClick2".play()
