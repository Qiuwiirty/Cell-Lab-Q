extends BaseCell
class_name SignalProducerCell
#Range from -20.0 to 20.0
var signals_production = [0.0, 0.0, 0.0, 0.0]

func _ready() -> void:
	super()
	$renders/nerve.material = $renders/nerve.material.duplicate()
func add_signals() -> void:
	for i in range(signals.size()):
		signals[i] += signals_production[i] / 10
		signals[i] = clamp(signals[i], -1.0, 1.0)

func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/nerve.scale = Vector2(radius / 15., radius / 15.)
	$renders/nerve.material.set_shader_parameter("cell_color", current_color)
	$renders/nerve.material.set_shader_parameter("aux", Vector4(
		clamp(signals_production[0] / 20.0, -1.0, 1.0)
		, 0.0, 0.0, 
		clamp(signals_production[1] / 20.0, -1.0, 1.0)
		))
	$renders/nerve.material.set_shader_parameter("aux2", Vector4(
		clamp(signals_production[2] / 20.0, -1.0, 1.0), 
		0.0, 0.0, 
		clamp(signals_production[3] / 20.0, -1.0, 1.0)
		))
func simulate_step(delta: float) -> void:
	super(delta)
	add_signals()
