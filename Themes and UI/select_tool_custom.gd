extends PanelContainer
###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###SELECT TOOL'S IMAGES: For setting image on ToolSelector
const CELL_SYNTHESIZER = preload("uid://byr8slrftdr2n")
const OPTICAL_TWEEZERS = preload("uid://bs57ivkpqnsjj")
const CELL_BOOST = preload("uid://b7eex3xh62xi7")
const CELL_REMOVAL = preload("uid://cw11ewl5y6str")
const CELL_DIAGNOSTICS = preload("uid://cxf7ocmrdrqxk")
const BIND_ADHESION = preload("uid://djx32y86pxg8q")
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


func _on_cell_synthesizer_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = CELL_SYNTHESIZER
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = CELL_SYNTHESIZER
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.CELL_SYNTHESIZER)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_optical_tweezers_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = OPTICAL_TWEEZERS
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = OPTICAL_TWEEZERS
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.OPTICAL_TWEEZERS)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_cell_boost_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = CELL_BOOST
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = CELL_BOOST
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.CELL_BOOST)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_cell_removal_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = CELL_REMOVAL
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = CELL_REMOVAL
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.CELL_REMOVAL)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_cell_diagnostics_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = CELL_DIAGNOSTICS
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = CELL_DIAGNOSTICS
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.CELL_DIAGNOSTICS)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_bind_adhesion_button_up() -> void:
	$VBoxContainer/MarginContainer/heading/icon.texture = BIND_ADHESION
	$"../TopPanel/Margin/Hbox/ToolSelector".icon = BIND_ADHESION
	if plate is Plate:
		plate.change_tool(Game.ToolSelector.BIND_ADHESION)
	else:
		print("Plate is invalid and therefore unable to set the tools")
	$"../ButtonClick2".play()
	close()
func _on_close_button_up() -> void:
	close()
