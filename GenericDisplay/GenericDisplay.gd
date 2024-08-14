extends PanelContainer

class_name GenericDisplay

@onready var element : Label = $GenericDisplay/GenericElementName
@onready var attributes : Label = $GenericDisplay/GenericElementAttributes

func _ready():
	GenericDisplaySignals.generic_display_highlight.connect(_on_display_highlight)

#Signal handling ---------------------------------------------------------------
func _on_display_highlight(highlighted_elements_names : Array):
	if (element.text in highlighted_elements_names):
		set_highlight_style()
	else:
		set_dimmed_style()

func _on_mouse_entered():
	GenericDisplaySignals.generic_display_over.emit(element.text)

func _on_mouse_exited():
	GenericDisplaySignals.generic_display_over.emit("")

#Text --------------------------------------------------------------------------
func set_text(text : String):
	var node : Label = get_node("GenericDisplay/GenericElementName")
	node.text = text

func set_info(info : String):
	var node : Label = get_node("GenericDisplay/GenericElementAttributes")
	node.text = "Real time info : \n" + info
	node.visible = false if (info == "") else true
#Background style --------------------------------------------------------------
func set_dimmed_style():
	set_bg_color(StyleConfig.DTElement.DIMMED_COLOR)

func set_highlight_style():
	set_bg_color(StyleConfig.DTElement.HIGHLIGHT_COLOR)

func set_bg_color(color : Color):
	var styleBox : StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	styleBox.bg_color = color
	add_theme_stylebox_override("panel", styleBox)

#Border style ------------------------------------------------------------------
func set_slower_style():
	set_border_color(StyleConfig.RTBorder.SLOWER_THAN_RT_COLOR)

func set_rt_style():
	set_border_color(StyleConfig.RTBorder.RT_COLOR)

func set_faster_style():
	set_border_color(StyleConfig.RTBorder.FASTER_THAN_RT_COLOR)

func set_border_color(color : Color):
	var styleBox : StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	styleBox.border_color = color
	styleBox.set_border_width_all(StyleConfig.RTBorder.BORDER_WIDTH)
	add_theme_stylebox_override("panel", styleBox)
