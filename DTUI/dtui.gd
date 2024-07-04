extends Control

@onready var service_container = $VBoxContainer/ServicesContainer
@onready var enabler_container = $VBoxContainer/EnablersContainer
@onready var model_container = $VBoxContainer/ModelsContainer

@onready var fuseki_data = $VBoxContainer/HBoxContainer/FusekiCallerButton/SparqlFusekiQueries/FusekiData

var generic_display = preload("res://GenericDisplay/generic_display.tscn")

func _on_fuseki_data_updated():
	update_node_with(service_container, fuseki_data.service)
	update_node_with(enabler_container, fuseki_data.enabler)
	update_node_with(model_container, fuseki_data.model)

func update_node_with(visual_container, fuseki_content):
	free_all_child(visual_container)
	for element in fuseki_content :
		var displayed_name: String = element[element.keys()[0]]["value"]
		displayed_name= displayed_name.split("#")[1]
		var new_display = generic_display.instantiate()
		new_display.get_node("Label").text = displayed_name
		visual_container.add_child(new_display)

func free_all_child(node):
	for child in node.get_children():
		child.queue_free()

