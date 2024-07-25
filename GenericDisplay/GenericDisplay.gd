extends BoxContainer

class_name GenericDisplay

@onready var element = $GenericElementName
@onready var element_name = $GenericElementName.text

func _ready():
	GenericDisplaySignals.generic_display_highlight.connect(_on_display_highlight)

#Signal handling ---------------------------------------------------------------
func _on_display_highlight(highlighted_elements_names : Array):
	if (element_name in highlighted_elements_names):
		set_highlight_style()
	else:
		set_dimmed_style()

func _on_mouse_entered():
	GenericDisplaySignals.generic_display_over.emit(element_name)

func _on_mouse_exited():
	GenericDisplaySignals.generic_display_over.emit("")

#Background style --------------------------------------------------------------
const dimmed_color : Color = Color.GRAY
const highlight_color : Color = Color.DIM_GRAY

func set_dimmed_style():
	set_bg_color(dimmed_color)

func set_highlight_style():
	set_bg_color(highlight_color)

func set_bg_color(color : Color):
	var styleBox : StyleBoxFlat = element.get_theme_stylebox("normal").duplicate()
	styleBox.bg_color = color
	element.add_theme_stylebox_override("normal", styleBox)

#Border style ------------------------------------------------------------------
const slower_color : Color = Color.BLUE_VIOLET
const rt_color : Color = Color.AQUAMARINE
const faster_color : Color = Color.GOLD

const border_width : int = 5

func set_slower_style():
	set_border_color(slower_color)

func set_rt_style():
	set_border_color(rt_color)

func set_faster_style():
	set_border_color(faster_color)

func set_border_color(color : Color):
	var styleBox : StyleBoxFlat = element.get_theme_stylebox("normal").duplicate()
	styleBox.border_color = color
	styleBox.set_border_width_all(border_width)
	element.add_theme_stylebox_override("normal", styleBox)
