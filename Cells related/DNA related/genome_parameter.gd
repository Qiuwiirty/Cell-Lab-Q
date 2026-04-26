extends Resource
class_name GenomeParam
enum Mode { FIXED, USE_STATE }
enum Formula {
	LINEAR,
	THRESHOLD
}
enum CellInput {
	INPUT_SIGNAL,
	CELL_MASS_DIV3_6, # div is divide, so divide by 3.6.
	CELL_AGE_DIV240,
	NITROGEN_RESERVE_DIV100,
	ADHESION_CONNECTION_DIV20
}
@export var force_fixed_value := false
#^ This will force use only the fixed value only regardless of mode
#This is important on int (enum), or on boolean fixed value
@export var mode: Mode = Mode.FIXED
@export var fixed_value = 0.0
@export var formula : Formula = Formula.LINEAR
#USE_STATE params
@export var input: CellInput = CellInput.INPUT_SIGNAL
@export var input_signal: int = 0  # S0, S1, S2...
@export var a: float = 1.0
@export var b: float = 0.0
@export var c: float = 0.0 

func get_value(cell: BaseCell) -> float:
	if mode == Mode.FIXED or force_fixed_value:
		return fixed_value
	var s
	match input:
		CellInput.INPUT_SIGNAL:
			s = cell.signals[input_signal] if input_signal < cell.signals.size() else 0.0
		CellInput.CELL_MASS_DIV3_6:
			s = cell.mass / 3.6
		CellInput.CELL_AGE_DIV240:
			s = cell.age / 240.
		CellInput.NITROGEN_RESERVE_DIV100:
			s = cell.nitrogen_reserve / 100.
		CellInput.ADHESION_CONNECTION_DIV20:
			s = cell.adhesion.size() / 20.
		_:
			print("Unkown CellInput. use Input signal instead")
			s = cell.signals[input_signal] if input_signal < cell.signals.size() else 0.0
	match formula:
		Formula.LINEAR:
			return a * s + b
		Formula.THRESHOLD:
			return a if s < c else b
		_:
			print("Unknown formula. Can't compute, use fixed value instead")
			return fixed_value
