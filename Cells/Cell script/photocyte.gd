extends BaseCell
class_name Photocyte

#These used for getting and reading image brightness to perform photosynthesis
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
	super()
	energy_loss_coefficient = 2
func _physics_process(delta: float) -> void:
	super(delta)
	#Photosynthesis
	mass += get_brightness() * Game.brightness_mult * delta
func get_brightness() -> float:
	var local_pos: Vector2 = $"../Platecolor".to_local(global_position)

	var pixel_x := int(local_pos.x + width * 0.5)
	var pixel_y := int(local_pos.y + height * 0.5)
	#check if pixel are out of bounds
	if (pixel_x >= width or pixel_x < 0) or (pixel_y >= height or pixel_y < 0):
		return 0.0
	var color := get_pixel_rgb8(pixel_x, pixel_y)
	return color.a

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

func correct_size() -> void:
	super()
	$render/green_floaters.scale = Vector2(0.029 * (radius / 15), 0.029 * (radius / 15))
