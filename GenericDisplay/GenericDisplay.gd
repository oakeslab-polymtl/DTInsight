extends PanelContainer

class_name GenericDisplay

@onready var element : Label = $GenericDisplay/GenericElementName
@onready var real_time_container = $GenericDisplay/RealTimeContainer
@onready var attributes : Label = $GenericDisplay/RealTimeContainer/GenericElementAttributes
@onready var pop_up : Popup = $Popup
@onready var chart : ChartControl = $Popup/ChartControl

var data : Array = []

func _ready():
	GenericDisplaySignals.generic_display_highlight.connect(_on_display_highlight)
	ChartSignals.hide.connect(_on_hide_pop_up_signal)

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

func _on_pop_up_button_pressed() -> void:
	chart.feed_historic(data)
	pop_up.show()

func _on_hide_pop_up_signal() -> void:
	pop_up.hide()

#Informations ------------------------------------------------------------------
func set_text(text : String):
	var node : Label = get_node("GenericDisplay/GenericElementName")
	node.text = text

func set_info(new_data : Array[String], is_bool = false):
	data = to_int_array(new_data, is_bool)
	var node : Label = get_node("GenericDisplay/RealTimeContainer/GenericElementAttributes")
	var last_data = data[data.size() - 1]
	var info : String = str(last_data) if (!is_bool) else "on" if (last_data == 1) else "off"
	node.text = "Real time info : \n" + info
	var real_time : VBoxContainer = get_node("GenericDisplay/RealTimeContainer")
	real_time.visible = false if (info.is_empty()) else true
	update_chart(last_data)

func to_int_array(str_array : Array[String], is_bool) -> Array:
	if is_bool:
		var int_array : Array = str_array.map(func(s) -> int : return int(s == "true")) as Array[int]
		return int_array
	else :
		var int_array : Array = str_array.map(func(s) -> int : return int(s)) as Array[int]
		return int_array

func update_chart(last_data) -> void:
	if pop_up.visible == false :
		return
	if not chart.up_to_date:
		chart.feed_historic(data)
	else :
		chart.add_value(last_data)

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
