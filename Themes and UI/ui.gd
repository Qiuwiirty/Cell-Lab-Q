extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.UI = self
	Game.emit_signal("UI_ready")
func set_diagnostics(info: String) -> void:
	if info == "false":
		$cell_diagnostics_panel.hide()
		return
	$cell_diagnostics_panel.show()
	$cell_diagnostics_panel/label.text = info
func _unhandled_input(event: InputEvent) -> void:
	#Open/close Substrate Temperature
	if event.is_action_pressed("1"):
		if $substrate_temperature.visible:
			$substrate_temperature.close()
		else:
			$substrate_temperature.open()
	#Open/close select tool 
	if event.is_action_pressed("2"):
		if $select_tool_custom.visible:
			$select_tool_custom.close()
		else:
			$select_tool_custom.open()
	#ui_cancel is escape. Close all popups
	if event.is_action_pressed("ui_cancel"):
		$select_tool_custom.close()
		$substrate_temperature.close()
		$configuration_panel.close()
