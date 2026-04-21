extends BaseCell
class_name Devorocyte
enum props{
	MASS_ABSORPTION_RATE
}
func _ready() -> void:
	super()
	$spikes.material = $spikes.material.duplicate()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$spikes.material.set_shader_parameter("cell_color", current_color * 0.5)
	$spikes.material.set_shader_parameter("cell_radius", radius / 15.0)
func simulate_step(delta: float) -> void:
	super(delta)
	#Devorocyte absorb 2 things: Mass and nitrates
	for cell in colliding:
		if cell is BaseCell and not cell.protected_devorocyte:
			var mass_absorption = mode.custprop[props.MASS_ABSORPTION_RATE] * delta
			mass = minf(mass + mass_absorption, 3.6)
			cell.mass -= mass_absorption
