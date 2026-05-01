extends BaseCell
class_name Flagellocyte
enum Props {
	SWIM_FORCE
}
var tail_phase := 0.0
func _ready() -> void:
	super()
	mode.cell_type = Game.CellType.FLAGELLOCYTE
	$renders/tail.material = $renders/tail.material.duplicate()

func simulate_step(delta: float) -> void:
	#Times 2500, because without it this will move extremely slow. At 0.01 swim force, need times 2500 to atleast match with the original cell lab
	var speed = Vector2(cos(rotation), sin(rotation)) * gprop(Props.SWIM_FORCE) * 2500 * delta 
	velocity += speed
	tail_phase += delta * (speed.length() * 2)
	if !mode.disable_metabolism:
		mass -= speed.length() / 2000
	super(delta)
	if mass <= 0:
		die()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/tail.material.set_shader_parameter("color", current_color * 0.5)
	$renders/tail.material.set_shader_parameter("t", tail_phase)
	$renders/tail.scale = Vector2(radius/15, radius/15)
	$renders/tail.position.x = -34.553 * radius/15 #-34.553 is the distance the flagellocytes to the center
