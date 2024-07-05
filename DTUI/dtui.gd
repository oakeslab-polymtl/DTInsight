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
	update_node_with(service_container, fuseki_data.service)
	update_node_with(enabler_container, fuseki_data.enabler)
	update_node_with(model_container, fuseki_data.model)
	queue_redraw()

func update_node_with(visual_container, fuseki_node_data):
	free_all_child(visual_container)
	for element in fuseki_node_data :
		var new_node = generic_display.instantiate()
		new_node.get_node("Label").text = element
		visual_container.add_child(new_node)
		var displayed_element = DisplayedNode.new()
		displayed_element.name = element
		displayed_element.node = new_node
		displayed_node_list.append(displayed_element)

func free_all_child(node):
	for child in node.get_children():
		child.queue_free()

func update_link_with(fuseki_link_data):
	if(fuseki_link_data == null):
		return
	for link in fuseki_link_data:
		var first_node_position = get_node_by_name(link.first_node).global_position
		var second_node_position = get_node_by_name(link.second_node).global_position
		print(first_node_position)
		print(second_node_position)
		print("----------------------")
		draw_line(first_node_position, second_node_position, Color.AQUA, 10, true)

func get_node_by_name(node_name : String):
	for displayed_node in displayed_node_list:
		if (displayed_node.name == node_name):
			return displayed_node.node
	return null

func _draw():
	update_link_with(fuseki_data.service_to_enabler)
