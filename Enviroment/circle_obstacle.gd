extends Area2D
class_name CircleObstacle
var current_diameter := 20.0
var mouse_over = false
func _ready() -> void:
	set_diameter(current_diameter)
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$MeshInstance2D.mesh = $MeshInstance2D.mesh.duplicate()
func set_diameter(diameter: float) -> void:
	$CollisionShape2D.shape.radius = diameter
	$MeshInstance2D.mesh.radius = diameter / 2
	$MeshInstance2D.mesh.height = diameter
	current_diameter = diameter

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func _unhandled_input(event: InputEvent) -> void:
	if Game.plate.tool_mode == Game.ToolSelector.OBSTACLE_EDITOR:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
			var obstacle_editor = Game.UI.get_node_or_null("obstacle_editor")
			if obstacle_editor:
				obstacle_editor.assign_obstacle(self)
				obstacle_editor.open()
				get_viewport().set_input_as_handled()
			else:
				print("OBSTACLE EDITOR DOES NOT EXIST")
