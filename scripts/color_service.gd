class_name ColorService
extends Node

enum ColorState { CYAN, MAGENTA, YELLOW, BLACK }

static func get_color(color_state: ColorState):
	match color_state:
		ColorState.CYAN: return Color.CYAN
		ColorState.MAGENTA: return Color.MAGENTA
		ColorState.YELLOW: return Color.YELLOW
	return Color.BLACK
