extends Control

#Reference each visual data container
@onready var service_container = $ServicesPanel/ServicesContainer
@onready var enabler_container = $EnablersPanel/EnablersContainer
@onready var model_container = $ModelsPanel/ModelsContainer

#Access to fuseki data
var fuseki_data = null

#Load the generic display scene
const generic_display = preload("res://GenericDisplay/generic_display.tscn")

#Displayes node referenced by its name
class DisplayedNode:
	var name : String
	var node

#Array of displayes nodes
var displayed_node_list: Array[DisplayedNode]

#Feed fuseki data
func feed_fuseki_data(feed):
	fuseki_data = feed
	on_fuseki_data_updated()

#Update all displayed information on data update from a signal from FusekiCallerButton
func on_fuseki_data_updated():
	displayed_node_list.clear()
	update_node_with(service_container, fuseki_data.service)
	update_node_with(enabler_container, fuseki_data.enabler)
	update_node_with(model_container, fuseki_data.model)
	queue_redraw()

#Update a node with Fuseki element data by creating a generic display node
func update_node_with(visual_container, fuseki_node_data : Dictionary):
	free_all_child(visual_container)
	for key in fuseki_node_data.keys():
		var new_node = generic_display.instantiate()
		new_node.get_node("GenericElementName").text = key
		visual_container.add_child(new_node)
		var displayed_element = DisplayedNode.new()
		displayed_element.name = key
		displayed_element.node = new_node
		displayed_node_list.append(displayed_element)
		
func _process(delta):
	queue_redraw()

#Free all childs of a node
static func free_all_child(node : Node):
	for child in node.get_children():
		if (child.get_class() == "VBoxContainer"):
			child.free()

#Format element attributes to be displayed as a string
static func build_displayed_string(attributes : Dictionary):
	var displayed_string = ""
	for key in attributes.keys():
		displayed_string += key + " : " + attributes[key] + "\n"
	return displayed_string

#Draw all links
func _draw():
	if (not fuseki_data == null):
		update_link_with(fuseki_data.service_to_enabler)
		update_link_with(fuseki_data.enabler_to_service)
		update_link_with(fuseki_data.model_to_enabler)
		update_link_with(fuseki_data.enabler_to_model)

#With Fuseki link data draw those links
func update_link_with(fuseki_link_data):
	if(fuseki_link_data == null):
		return
	for link in fuseki_link_data:
		var first_node = get_node_by_name(link.first_node_name)
		var second_node = get_node_by_name(link.second_node_name)
		var drawing_positions = get_facing_sides(first_node, second_node)
		draw_upstream(drawing_positions) if (drawing_positions[0].y > drawing_positions[1].y) else draw_downstream(drawing_positions)

func draw_upstream(drawing_positions):
	var color = Color.GREEN_YELLOW
	var position0 = shift_position(drawing_positions[0], 10)
	var position1 = shift_position(drawing_positions[1], 10)
	draw_line(position0, position1, color, 7, true)
	draw_circle(position1, 10, color)

func draw_downstream(drawing_positions):
	var color = Color.BROWN
	var position0 = shift_position(drawing_positions[0], -10)
	var position1 = shift_position(drawing_positions[1], -10)
	draw_line(position0, position1, color, 7, true)
	draw_circle(position1, 10, color)

static func shift_position(position : Vector2, shift_value) -> Vector2:
	return Vector2(position.x + shift_value, position.y)

#Return a node by its nale in the displayes_node_list
func get_node_by_name(node_name : String):
	for displayed_node in displayed_node_list:
		if (displayed_node.name == node_name && displayed_node.node != null):
			return displayed_node.node
	var displayed_node_list_string = ""
	for displayed_node in displayed_node_list:
		displayed_node_list_string += displayed_node.name
	print(node_name + " not found in " + displayed_node_list_string)
	return null

#Return facing positions on the side of each node
static func get_facing_sides(first_node, second_node) -> Array[Vector2]:
	if (first_node.global_position.y < second_node.global_position.y):
		return [get_bottom_side(first_node), get_top_side(second_node)]
	return [get_top_side(first_node), get_bottom_side(second_node)]

#Return a position on the middle and bottom of a node
static func get_bottom_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(position.x + size.x / 2, position.y + size.y)
	return corrected_position

#Return a postition on the middle and top of a node
static func get_top_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(position.x + size.x / 2, position.y)
	return corrected_position
