extends BaseCell
class_name Flagellocyte
enum {
	SWIM_FORCE
}
var tail_phase := 0.0
func _ready() -> void:
	super()
	mode.cell_type = Game.CellType.FLAGELLOCYTE
	mode.set_up_custom_properties() #if there properties that missing this fixed it
	$tail_quad.material = $tail_quad.material.duplicate()

func simulate_step(delta: float) -> void:
	var speed = Vector2(cos(rotation), sin(rotation)) * mode.custprop[SWIM_FORCE] * delta
	velocity += speed
	tail_phase += delta * (speed.length() * 2)
	mass -= speed.length() / 2000
	super(delta)
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$tail_quad.material.set_shader_parameter("color", current_color * 0.75)
	$tail_quad.material.set_shader_parameter("t", tail_phase)
	#Direction the tail points (opposite to movement)
	var angle = velocity.angle() + PI
	#Offset from cell center to tail base (34px in the tail direction) which is adjusted by the radius btw
	var offset = Vector2(cos(angle), sin(angle)) * (34.0 * radius/15)
	$tail_quad.position = offset
	$tail_quad.rotation = angle
	$tail_quad.scale = Vector2(radius/15, radius/15)
