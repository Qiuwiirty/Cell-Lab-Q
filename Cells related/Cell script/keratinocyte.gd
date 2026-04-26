extends BaseCell
class_name Keratinocyte

func _ready() -> void:
	super()
	protected_devorocyte = true
	protected_injury = true
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/render_quad.material.set_shader_parameter("ring_radius", (radius / 15) * 0.4)

func simulate_step(delta: float) -> void:
	super(delta)
	for cell in adhesion:
		cell.protected_devorocyte = true
		cell.protected_injury = true

func die(create_food := true) -> void:
	super(create_food)
	for cell in adhesion:
		if cell is not Keratinocyte:
			cell.update_protected()
