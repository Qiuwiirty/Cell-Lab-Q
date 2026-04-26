extends BaseCell
class_name Devorocyte
enum Props{
	MASS_ABSORPTION_RATE
}
func _ready() -> void:
	super()
	$renders/spikes.material = $renders/spikes.material.duplicate()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/spikes.material.set_shader_parameter("cell_color", current_color * 0.5)
	$renders/spikes.material.set_shader_parameter("cell_radius", radius / 15.0)
func simulate_step(delta: float) -> void:
	super(delta)
	#Devorocyte absorb 2 things: Mass and nitrates
	for cell in colliding:
		if cell is BaseCell and not cell.protected_devorocyte:
			var mass_absorption = gprop(Props.MASS_ABSORPTION_RATE) * delta
			mass = minf(mass + mass_absorption, 3.6)
			cell.mass -= mass_absorption
