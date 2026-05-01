extends MeshInstance2D
class_name DeathCell
var radius := 1.0
var progress := 0.0
var color := Color(1.0, 1.0, 1.0, 1.0)
var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0
func _ready() -> void:
	material = material.duplicate()
	material.set_shader_parameter("cell_color", color)
	material.set_shader_parameter("cell_radius", (radius / 15) * 0.4753)
func _process(delta: float) -> void:
	accumulator += delta * Game.timescale_modifier()
	while accumulator >= FIXED_STEP:
		if progress >= 35.:
			queue_free()
		progress += FIXED_STEP * 40
		material.set_shader_parameter("death_progress", progress)
		accumulator -= FIXED_STEP
