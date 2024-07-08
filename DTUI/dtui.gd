extends Control

@onready var service_container = $VBoxContainer/ServicesContainer
@onready var enabler_container = $VBoxContainer/EnablersContainer
@onready var model_container = $VBoxContainer/ModelsContainer

@onready var fuseki_data = $VBoxContainer/HBoxContainer/FusekiCallerButton/SparqlFusekiQueries/FusekiData

var generic_display = preload("res://GenericDisplay/generic_display.tscn")

class DisplayedNode:
	var name : String
	var node

var displayed_node_list: Array[DisplayedNode]

func _on_fuseki_data_updated():
	displayed_node_list.clear()
	update_node_with(service_container, fuseki_data.service)
	update_node_with(enabler_container, fuseki_data.enabler)
	update_node_with(model_container, fuseki_data.model)
	queue_redraw()

func update_node_with(visual_container, fuseki_node_data):
	free_all_child(visual_container)
	for element in fuseki_node_data :
		var new_node = generic_display.instantiate()
		new_node.get_node("GenericElementName").text = element.element_name
		new_node.get_node("GenericElementAttributes").text = build_displayed_string(element.element_attributes)
		visual_container.add_child(new_node)
		var displayed_element = DisplayedNode.new()
		displayed_element.name = element.element_name
		displayed_element.node = new_node
		displayed_node_list.append(displayed_element)

func free_all_child(node):
	for child in node.get_children():
		child.free()

func build_displayed_string(attributes):
	var displayed_string = ""
	for key in attributes.keys():
		displayed_string += key + " : " + attributes[key] + "\n"
	return displayed_string

func _draw():
	update_link_with(fuseki_data.service_to_enabler)
	update_link_with(fuseki_data.enabler_to_service)
	update_link_with(fuseki_data.model_to_enabler)
	
func update_link_with(fuseki_link_data):
	if(fuseki_link_data == null):
		return
	for link in fuseki_link_data:
		var first_node = get_node_by_name(link.first_node_name)
		var second_node = get_node_by_name(link.second_node_name)
		var drawing_positions = get_facing_sides(first_node, second_node)
		draw_line(drawing_positions[0], drawing_positions[1], Color.AQUA, 7, true)
		draw_circle(drawing_positions[1], 10, Color.AQUA)

func get_node_by_name(node_name : String):
	for displayed_node in displayed_node_list:
		if (displayed_node.name == node_name):
			return displayed_node.node
	return null

func get_facing_sides(first_node, second_node) -> Array[Vector2]:
	if (first_node.global_position.y < second_node.global_position.y):
		return [get_bottom_side(first_node), get_top_side(second_node)]
	return [get_top_side(first_node), get_bottom_side(second_node)]
	
func get_bottom_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(position.x + size.x / 2, position.y + size.y)
	return corrected_position

func get_top_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(position.x + size.x / 2, position.y)
	return corrected_position
