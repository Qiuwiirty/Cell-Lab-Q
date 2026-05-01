extends BaseCell
class_name Stemocyte
enum Props{
	DIFF_PATH_1_MODE, #mode (M0, ...)
	PATH_1_SIGNAL, #genome param (Fixed value range from -1.0, to 1.0)
	DIFF_PATH_2_MODE,
	PATH_2_SIGNAL
}
func _ready() -> void:
	super()
	$renders/stemo.material = $renders/stemo.material.duplicate()
func simulate_step(delta: float) -> void:
	super(delta)
	if gprop(Props.PATH_1_SIGNAL) > 0.5:
		if gprop(Props.DIFF_PATH_1_MODE) != current_mode:
			turn_into_mode(gprop(Props.DIFF_PATH_1_MODE))
	elif gprop(Props.PATH_2_SIGNAL) > 0.5:
		if gprop(Props.DIFF_PATH_2_MODE) != current_mode:
			turn_into_mode(gprop(Props.DIFF_PATH_2_MODE))
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	
	var sig1 = gprop(Props.PATH_1_SIGNAL)
	var sig2 = gprop(Props.PATH_2_SIGNAL)
	
	var balance = (sig1 - sig2) / 2.0
	
	var strength = 0.5 
	var red  = clamp(0.75 + balance * strength, 0.0, 1.0)
	var blue = clamp(0.75 - balance * strength, 0.0, 1.0)
	$renders/stemo.scale = Vector2(radius / 15., radius / 15.)
	$renders/stemo.material.set_shader_parameter("red_substance", red)
	$renders/stemo.material.set_shader_parameter("blue_substance", blue)
