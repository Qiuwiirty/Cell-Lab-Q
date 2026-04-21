extends BaseCell
class_name Buoyocyte
enum props{
	DENSITY
}
func _ready() -> void:
	super()
	$buoy_quad.material = $buoy_quad.material.duplicate()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$buoy_quad.material.set_shader_parameter("color", current_color)
	$buoy_quad.scale = Vector2(radius / 15., radius / 15.)
func simulate_step(delta: float) -> void:
	super(delta)
	velocity.y += mode.custprop[props.DENSITY] * conf[Game.SubsConf.GRAVITY] * delta
