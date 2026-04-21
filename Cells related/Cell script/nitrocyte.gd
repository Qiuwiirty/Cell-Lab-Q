extends BaseCell
class_name Nitrocyte
func _ready() -> void:
	super()
	$fractal_quad.material = $fractal_quad.material.duplicate()
func simulate_step(delta: float) -> void:
	super(delta)
	#constantly add nitrogen reserve
	nitrogen_reserve = min(nitrogen_reserve + 10.0 * delta, 100)
func correct_appearance(delta, modify_color_radius = true) -> void:
	super(delta, modify_color_radius)
	$fractal_quad.material.set_shader_parameter("color", current_color * 0.5)
	$fractal_quad.scale = Vector2(radius / 15., radius / 15.)
