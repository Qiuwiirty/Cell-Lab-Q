extends BaseCell
class_name Flagellocyte
enum props {
	SWIM_FORCE
}
var tail_phase := 0.0
func _ready() -> void:
	super()
	mode.cell_type = Game.CellType.FLAGELLOCYTE
	$tail_quad.material = $tail_quad.material.duplicate()

func simulate_step(delta: float) -> void:
	var speed = Vector2(cos(rotation), sin(rotation)) * mode.custprop[props.SWIM_FORCE] * delta
	velocity += speed
	tail_phase += delta * (speed.length() * 2)
	if !mode.disable_metabolism:
		mass -= speed.length() / 2000
	super(delta)
	if mass <= 0:
		die()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$tail_quad.material.set_shader_parameter("color", current_color * 0.5)
	$tail_quad.material.set_shader_parameter("t", tail_phase)
	$tail_quad.scale = Vector2(radius/15, radius/15)
	$tail_quad.position.x = -34.0 * radius/15
