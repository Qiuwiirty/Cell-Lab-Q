extends BaseCell
class_name Photocyte

var width
var height
var format

var data: PackedByteArray

func _ready():
	var img: Image = preload("res://platecolor.png").get_image()
	img.convert(Image.FORMAT_RGBA8)
	width = img.get_width()
	height = img.get_height()
	data = img.get_data()
	
	var local_pos: Vector2 = $"../Platecolor".to_local(global_position)
	var img_size := img.get_size()

	var pixel_x := int(local_pos.x + img_size.x * 0.5)
	var pixel_y := int(local_pos.y + img_size.y * 0.5)
	pixel_x = clamp(pixel_x, 0, img_size.x - 1)
	pixel_y = clamp(pixel_y, 0, img_size.y - 1)
	print("x:", pixel_x, "y: ",pixel_y)
	var color := get_pixel_rgb8(pixel_x, pixel_y)
	print(color)
	super()
	energy_loss_coefficient = 2

func get_pixel_rgb8(
		x: int,
		y: int,
	) -> Color:
	var idx = (y * width + x) * 4
	return Color(
		data[idx]     / 255.0,
		data[idx + 1] / 255.0,
		data[idx + 2] / 255.0,
		data[idx + 3] / 255.0
	)
