extends PanelContainer
@onready var plate = get_parent().get_parent()

###SELECT TOOL'S IMAGES: For setting image on ToolSelector
const cell_synthesizer = preload("uid://byr8slrftdr2n")
const optical_tweezers = preload("uid://bs57ivkpqnsjj")
const cell_boost = preload("uid://b7eex3xh62xi7")
const cell_removal = preload("uid://cw11ewl5y6str")
const cell_diagnostics = preload("uid://cxf7ocmrdrqxk")

###SUBSTRATE TEMPERATURE'S IMAGES: For setting image on TemperatureButton
const FREEZE = preload("uid://4f2i66tbqreo")
const SLOW_OBSERVE = preload("uid://p5fmju3af5d7")
const OBSERVE = preload("uid://6md56mn5ckjp")
const INCUBATE = preload("uid://dg2wqbvy11mos")

func _on_sterilize_button_up() -> void:
	$Margin/Hbox/SterilizeButton/Sterilize.play()
	Game.sterilize()
	$"../SterilizeRectEffect".modulate = Color(1.0, 1.0, 1.0, 0.5)
	$"../SterilizeRectEffect".show()
	var tween = create_tween()
	tween.tween_property($"../SterilizeRectEffect", "modulate:a", 0.0, 0.5)
	tween.tween_callback($"../SterilizeRectEffect".hide)

func _on_tool_selector_button_up() -> void:
	$"../ButtonClick".play()
	if not $"../select_tool_custom".visible:
		$"../select_tool_custom".open()
	else:
		$"../select_tool_custom".close()
func _on_select_tool_pressed(id: int) -> void:
	$"../ButtonClick2".play()
	if plate is not Plate:
		print("The plate is incorrect and unable to change tool. ", "The plate simply did not exist" if !plate else "The name of the incorrect object is: " + plate.name)
		return
	match id:
		Game.ToolSelector.CELL_SYNTHESIZER:
			plate.change_tool(Game.ToolSelector.CELL_SYNTHESIZER)
			$Margin/Hbox/ToolSelector.icon = cell_synthesizer
		Game.ToolSelector.OPTICAL_TWEEZERS:
			plate.change_tool(Game.ToolSelector.OPTICAL_TWEEZERS)
			$Margin/Hbox/ToolSelector.icon = optical_tweezers
		Game.ToolSelector.CELL_BOOST:
			plate.change_tool(Game.ToolSelector.CELL_BOOST)
			$Margin/Hbox/ToolSelector.icon = cell_boost
		Game.ToolSelector.CELL_REMOVAL:
			plate.change_tool(Game.ToolSelector.CELL_REMOVAL)
			$Margin/Hbox/ToolSelector.icon = cell_removal
		Game.ToolSelector.CELL_DIAGNOSTICS:
			plate.change_tool(Game.ToolSelector.CELL_DIAGNOSTICS)
			$Margin/Hbox/ToolSelector.icon = cell_diagnostics


func _on_temperature_button_up() -> void:
	$"../ButtonClick".play()
	if not $"../substrate_temperature".visible:
		$"../substrate_temperature".open()
	else:
		$"../substrate_temperature".close()
func _on_substrate_temperature_id_pressed(id: int) -> void:
	$"../ButtonClick2".play()
	if plate is not Plate:
		print("The plate is incorrect and unable to change temperature. ", "The plate simply did not exist" if !plate else "The name of the incorrect object is: " + plate.name)
		return
	plate.change_substrate_temperature(id)
	match id:
		Game.SubstrateTemperature.FREEZE:
			$Margin/Hbox/TemperatureButton.icon = FREEZE
		Game.SubstrateTemperature.SLOW_OBSERVE:
			$Margin/Hbox/TemperatureButton.icon = SLOW_OBSERVE
		Game.SubstrateTemperature.OBSERVE:
			$Margin/Hbox/TemperatureButton.icon = OBSERVE
		Game.SubstrateTemperature.INCUBATE:
			$Margin/Hbox/TemperatureButton.icon = INCUBATE
