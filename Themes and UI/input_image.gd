extends HBoxContainer
#for non-mathematical lighting photosynthesis
func _ready() -> void:
	$Button.text = Game.current_path

func _on_button_up() -> void:
	$FileDialog.popup_centered()

func _on_file_dialog_file_selected(path: String) -> void:
	$Button.text = path
	Game.current_path = path
	Game.load_file(path)
	Game.plate.change_mathematical_lighting()
