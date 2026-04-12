extends Area2D
class_name RectObstacle
var current_size := Vector2(20., 20.)
var mouse_over := false
func _ready() -> void:
	set_size(current_size)
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$MeshInstance2D.mesh = $MeshInstance2D.mesh.duplicate()
func set_size(size: Vector2) -> void:
	$CollisionShape2D.shape.size = size
	$MeshInstance2D.mesh.size = size
	current_size = size

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func _unhandled_input(event: InputEvent) -> void:
	if Game.plate.tool_mode == Game.ToolSelector.OBSTACLE_EDITOR:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.shift_pressed:
			var obstacle_editor = Game.UI.get_node_or_null("obstacle_editor")
			if obstacle_editor:
				obstacle_editor.assign_obstacle(self)
				obstacle_editor.open()
				get_viewport().set_input_as_handled()
			else:
				print("OBSTACLE EDITOR DOES NOT EXIST")

#func _on_area_entered(area: Area2D) -> void:
	#if area is Food:
		#area.queue_free()
