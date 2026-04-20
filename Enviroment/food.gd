extends Area2D
class_name Food
###Mobility of a food (Whether the food can move or not) determined by setting the var 'freeze'
#It needs approximately 192 seconds for a food in cell lab to decay, but it's different here
@export var nutrition = 15 #Max is 15
@export var coating = 0.0
enum SpawnShape 
{
	RECTANGLE,
	CIRCLE
}
var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0
func _ready() -> void:
	var mods = nutrition / 15.
	$CollisionShape2D.scale = Vector2(mods, mods)
	$MeshInstance2D.scale = Vector2(mods, mods)
	$MeshInstance2D.modulate = Color(1.0, 1.0 - (coating / 15), 1.0 - (coating / 15), 1.0)
func _process(delta: float) -> void:
	if nutrition <= 0.01:
		queue_free()
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		return
	accumulator += delta * Game.timescale_modifier()
	while accumulator >= FIXED_STEP:
		nutrition -= (15. / nutrition) * 0.1 *  FIXED_STEP
		accumulator -= FIXED_STEP
	var mods = nutrition / 15.
	$CollisionShape2D.scale = Vector2(mods, mods)
	$MeshInstance2D.scale = Vector2(mods, mods)
	#$MeshInstance2D.modulate = Color(1.0, .68 - (coating / 10) * .68, 0.211, 0.545)
	$MeshInstance2D.modulate = Color(1.0, 1.0 - (coating / 15), 1.0 - (coating / 15), 1.0)
