extends HBoxContainer

class_name LegendElement

func set_color(color : Color):
	var color_container : ColorRect = get_node("Color")
	color_container.color = color

func set_text(text : String):
	var text_container : Label = get_node("Label")
	text_container.text = text
