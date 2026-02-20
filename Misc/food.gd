extends RigidBody2D
class_name Food
###Mobility of a food (Whether the food can move or not) determined by setting the var 'freeze'
@export var nutrition = 10
@export var coating = 0.0
func _process(delta: float) -> void:
	nutrition -= 0.06 * delta
	var mods = nutrition / 10
	$CollisionShape2D.scale = Vector2(mods, mods)
	$MeshInstance2D.scale = Vector2(mods, mods)
	$MeshInstance2D.modulate = Color(1.0, .68 - (coating / 10) * .68, 0.211, 0.545)
