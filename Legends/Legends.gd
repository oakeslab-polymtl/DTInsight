extends Container

@onready var retract_button = $RetractButton
@onready var legends_panel = $PanelContainer
@onready var legends_container = $PanelContainer/LegendsContainer

const LegendElement = preload("res://Legends/LegendElement.tscn")

func _ready() -> void:
	set_retract_button_color(StyleConfig.Legends.RETRACT_BUTTON_COLOR)
	set_panel_color(StyleConfig.Legends.PANEL_COLOR)
	build_legends(LegendsConfig.LEGENDS)

func set_retract_button_color(color : Color):
	var buttonStylebox : StyleBoxFlat = retract_button.get_theme_stylebox("normal").duplicate()
	buttonStylebox.bg_color = color
	retract_button.add_theme_stylebox_override("normal", buttonStylebox)

func set_panel_color(color : Color):
	var panelStylebox : StyleBoxFlat = legends_panel.get_theme_stylebox("normal").duplicate()
	panelStylebox.bg_color = color
	legends_panel.add_theme_stylebox_override("normal", panelStylebox)

func build_legends(legends : Dictionary):
	for categoryKey : String in legends.keys():
		add_legend_indicator(categoryKey)
		for legend in legends[categoryKey].keys():
			instanciate_legend_element(legend, legends[categoryKey][legend])

func add_legend_indicator(legend : String):
	var new_label : Label = Label.new()
	new_label.text = legend
	new_label.add_theme_color_override("font_color", StyleConfig.Legends.CATEGORY_ANNONCE_COLOR)
	legends_container.add_child(new_label)

func instanciate_legend_element(text : String, color : Color):
	var new_legend_element : LegendElement = LegendElement.instantiate()
	new_legend_element.set_text(text)
	new_legend_element.set_color(color)
	legends_container.add_child(new_legend_element)

#Hiding function ---------------------------------------------------------------------------------
var legends_hidden : bool  = false

func _on_retract_button_pressed() -> void:
	hide_legends()

func hide_legends():
	var translate_distance = legends_panel.size.y + 20
	if (legends_hidden):
		translate_distance = -translate_distance
		retract_button.text = StyleConfig.Legends.GO_AWAY_TEXT
	else:
		retract_button.text = StyleConfig.Legends.COME_IN_TEXT
	legends_hidden = !legends_hidden
	position += Vector2(0, translate_distance)
