extends BoxContainer

@onready var element = $GenericElementName
@onready var element_name = $GenericElementName.text

const dimmed_color : Color = Color.GRAY
const highlight_color : Color = Color.DIM_GRAY

func _ready():
	set_dimmed_style()
	GenericDisplaySignals.generic_display_highlight.connect(_on_display_highlight)

func _on_display_highlight(highlighted_elements_names : Array):
	if (element_name in highlighted_elements_names):
		set_highlight_style()
	else:
		set_dimmed_style()

func _on_mouse_entered():
	GenericDisplaySignals.generic_display_over.emit(element_name)

func _on_mouse_exited():
	GenericDisplaySignals.generic_display_over.emit("")

func set_dimmed_style():
	set_bg_color(dimmed_color)

func set_highlight_style():
	set_bg_color(highlight_color)

func set_bg_color(color : Color):
	var styleBox : StyleBoxFlat = element.get_theme_stylebox("normal").duplicate()
	styleBox.set("bg_color", color)
	element.add_theme_stylebox_override("normal", styleBox)
