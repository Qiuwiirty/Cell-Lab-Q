extends PanelContainer
var genome_param: GenomeParam
func _ready() -> void:
	for i in GenomeParam.Mode.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.add_item(GenomeParam.Mode.keys()[i], i)
	for i in GenomeParam.CellInput.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/input/OptionButton.add_item(GenomeParam.CellInput.keys()[i], i)
	for i in GenomeParam.Formula.keys().size():
		$VBoxContainer/ScrollContainer/VBoxContainer/input/OptionButton.add_item(GenomeParam.Formula.keys()[i], i)

func _on_mode_selected(index: int) -> void:
	genome_param.mode = index as GenomeParam.Mode
	
func _on_fixed_value_changed(value: float) -> void:
	if genome_param.fixed_value is float:
		genome_param.fixed_value = value
	elif genome_param.fixed_value is int:
		genome_param.fixed_value = round(value)
	elif genome_param.fixed_value is bool:
		if value == 1.:
			genome_param.fixed_value = true
		else:
			genome_param.fixed_value = false
	else:
		print("Genome parameter's fixed value has a type that can't be processed. The value of it is: ", value)
func _on_input_selected(index: int) -> void:
	genome_param.input = index as GenomeParam.CellInput

func _on_value_formula_selected(index: int) -> void:
	genome_param.formula = index as GenomeParam.Formula

func _on_a_value_changed(value: float) -> void:
	genome_param.a = value

func _on_b_value_changed(value: float) -> void:
	genome_param.b = value

func _on_c_value_changed(value: float) -> void:
	genome_param.c = value

func update_values() -> void:
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.max_value = 1000.
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.min_value = -1000.
	$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 0.001
	$VBoxContainer/ScrollContainer/VBoxContainer/warning.hide()
	$VBoxContainer/ScrollContainer/VBoxContainer/info_bool.hide()
	if genome_param.force_fixed_value:
		$VBoxContainer/ScrollContainer/VBoxContainer/warning.show()
	if genome_param.fixed_value is bool:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.max_value = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.min_value = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = 1.0 if genome_param.fixed_value else 0.0
		$VBoxContainer/ScrollContainer/VBoxContainer/info_bool.show()
	elif genome_param.fixed_value is int:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.step = 1.0
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = genome_param.fixed_value
	elif genome_param.fixed_value is float:
		$VBoxContainer/ScrollContainer/VBoxContainer/fixed_value/SpinBox.value = genome_param.fixed_value
	$VBoxContainer/ScrollContainer/VBoxContainer/mode/OptionButton.selected = genome_param.mode
	$VBoxContainer/ScrollContainer/VBoxContainer/input/OptionButton.selected = genome_param.input
	$VBoxContainer/ScrollContainer/VBoxContainer/value/OptionButton.selected = genome_param.formula
	$VBoxContainer/ScrollContainer/VBoxContainer/a/SpinBox.value = genome_param.a
	$VBoxContainer/ScrollContainer/VBoxContainer/b/SpinBox.value = genome_param.b
	$VBoxContainer/ScrollContainer/VBoxContainer/c/SpinBox.value = genome_param.c
