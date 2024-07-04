extends Control

@onready var service_container = $VBoxContainer/ServicesContainer
@onready var enabler_container = $VBoxContainer/EnablersContainer
@onready var model_container = $VBoxContainer/ModelsContainer

@onready var fuseki_caller = $VBoxContainer/HBoxContainer/FusekiCallerButton

var generic_display = preload("res://generic_display.tscn")

func _on_fuseki_data_updated():
	update_node_with("service", service_container, fuseki_caller.service)
	update_node_with("enabler", enabler_container, fuseki_caller.enabler)
	update_node_with("model", model_container, fuseki_caller.model)

func update_node_with(node_name, visual_container, fuseki_content):
	free_all_child(visual_container)
	for element in fuseki_content :
		print(element)
		var displayed_name: String = element[node_name]["value"]
		displayed_name= displayed_name.split("#")[1]
		var new_display = generic_display.instantiate()
		new_display.get_node("Label").text = displayed_name
		visual_container.add_child(new_display)

func free_all_child(node):
	for child in node.get_children():
		child.queue_free()

