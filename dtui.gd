extends Control

@onready var services_container = $VBoxContainer/ServicesContainer
@onready var enablers_container = $VBoxContainer/EnablersContainer
@onready var models_container = $VBoxContainer/ModelsContainer

@onready var fuseki_caller = $VBoxContainer/HBoxContainer/FusekiCallerButton

var generic_display = preload("res://generic_display.tscn")

func _on_fuseki_caller_button_services_updated():
	update_node_with(services_container, "service", fuseki_caller.services)

func _on_fuseki_caller_button_enablers_updated():
	update_node_with(enablers_container, "enabler", fuseki_caller.enablers)

func _on_fuseki_caller_button_models_updated():
	update_node_with(models_container, "model", fuseki_caller.models)

func update_node_with(node, node_name, content):
	free_all_child(node)
	for element in content :
		print(element)
		var displayed_name: String = element[node_name]["value"]
		displayed_name= displayed_name.split("#")[1]
		var new_display = generic_display.instantiate()
		new_display.get_node("Label").text = displayed_name
		node.add_child(new_display)

func free_all_child(node):
	for child in node.get_children():
		child.queue_free()
