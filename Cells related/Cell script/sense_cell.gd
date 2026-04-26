extends SignalProducerCell #Note basecell has already the var signals
class_name SenseCell
enum SenseType
{
	CELL,
	FOOD,
	COATED_FOOD,
	LIGHT,
	VELOCITY,
	WALL
}
enum Props
{
	SENSE_TYPE,
	OUTPUT_CHANNEL,
	OUTPUT,
	SENSE_RED,
	SENSE_GREEN,
	SENSE_BLUE,
	COLOR_THRESHOLD
}
#The constant is unknown, but this is the closest approx. I could find
const C := 1.0 
const R0 := 75.0
var cells_in_area: Array[BaseCell]
var foods_in_area: Array[Food]
func _ready() -> void:
	super()
	energy_loss_coefficient = 0.1
#Fancy decay curve
func bessel_k0(x: float) -> float:
	x = max(x, 0.001)
	if x <= 2.0:
		var t = x * x / 4.0
		return (-log(x / 2.0) * (1.0 + t * (0.25 + t * (0.015625 + t * 0.000434)))) \
			 + (-0.5772 + t * (0.4228 + t * (0.2307 + t * 0.0348)))
	else:
		return sqrt(PI / (2.0 * x)) * exp(-x)
func color_matches(cell: BaseCell) -> bool:
	var dr = gprop(Props.SENSE_RED) - cell.current_color.r
	var dg = gprop(Props.SENSE_GREEN) - cell.current_color.g
	var db = gprop(Props.SENSE_BLUE) - cell.current_color.b
	return sqrt(dr*dr + dg*dg + db*db) < gprop(Props.COLOR_THRESHOLD)
func sense_cell(cell: BaseCell) -> float:
	if not color_matches(cell):
		return 0.0
	var r := global_position.distance_to(cell.global_position)
	return gprop(Props.OUTPUT) * C * bessel_k0(r / R0)
func sense_food(food: Food) -> float:
	var r := global_position.distance_to(food.global_position)
	var m : float = food.nutrition 
	return gprop(Props.OUTPUT) * m * C * bessel_k0(r / R0)
func sense_phase() -> void:
	var channel = gprop(Props.OUTPUT_CHANNEL)
	signals_production[channel] = 0.0
	match gprop(Props.SENSE_TYPE):
		SenseType.CELL:
			for cell in cells_in_area:
				if cell == self: continue
				signals_production[channel] += sense_cell(cell)
		SenseType.FOOD:
			for food in foods_in_area:
				signals_production[channel] += sense_food(food)
func add_signals() -> void:
	for i in range(signals.size()):
		signals[i] += signals_production[i] / 10
		signals[i] = clamp(signals[i], -1.0, 1.0)
func simulate_step(delta: float) -> void:
	super(delta)
	sense_phase()
