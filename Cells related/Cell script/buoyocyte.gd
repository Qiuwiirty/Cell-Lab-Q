extends BaseCell
class_name Buoyocyte
enum Props{
	DENSITY
}
func _ready() -> void:
	super()
	$renders/buoy.material = $renders/buoy.material.duplicate()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/buoy.material.set_shader_parameter("color", current_color)
	$renders/buoy.scale = Vector2(radius / 15., radius / 15.)
func simulate_step(delta: float) -> void:
	super(delta)
	velocity.y += gprop(Props.DENSITY) * conf[Game.SubsConf.GRAVITY] * delta
