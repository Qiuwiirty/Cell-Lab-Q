extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.UI = self
func set_diagnostics(info: String) -> void:
	if info == "false":
		$cell_diagnostics_panel.hide()
		return
	$cell_diagnostics_panel.show()
	$cell_diagnostics_panel/label.text = info
