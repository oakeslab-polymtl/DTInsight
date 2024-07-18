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

#Link width
const link_width : int = 5

#displayed coordinates collection
var already_drawn_x : Array[int] = []
var already_drawn_y : Array[int] = []

#link display colot
const dimmed_color : Color = Color.GRAY
const highlight_color : Color = Color.DIM_GRAY

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
	already_drawn_x.clear()
	already_drawn_y.clear()
	queue_redraw()

#Free all childs of a node
static func free_all_child(node : Node):
	for child in node.get_children():
		if (child.get_class() == "BoxContainer"):
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

#With Fuseki link data draw those links
func update_link_with(fuseki_link_data):
	if(fuseki_link_data == null):
		return
	var links_as_dict : Dictionary = to_link_dictionary(fuseki_link_data)
	for key in links_as_dict.keys():
		var drawable_y_position = get_drawable_y_height(key, links_as_dict[key])
		var x_drawn : Array[int] = []
		x_drawn.append(draw_element_to_lane(key, drawable_y_position))
		for association_element in links_as_dict[key]:
			x_drawn.append(draw_element_to_lane(association_element, drawable_y_position, true))
		var most_left_x_position : int = x_drawn.min() - round(link_width / 2 - 0.5)
		var most_right_x_position : int = x_drawn.max() + round(link_width / 2 + 0.5)
		draw_link_lane(most_left_x_position, most_right_x_position, drawable_y_position)

func draw_element_to_lane(node, drawable_y_position : int, destination : bool = false) -> int:
	var is_pointing_up : bool = node.global_position.y < drawable_y_position
	var drawing_position_element : Vector2 = get_bottom_side(node) if (is_pointing_up) else get_top_side(node)
	var adjusted_x : int = get_drawable_x_position(drawing_position_element.x)
	var vertical_shift : int = draw_triangle(Vector2(adjusted_x, drawing_position_element.y), is_pointing_up) if destination else 0
	draw_line(Vector2(adjusted_x, drawing_position_element.y + vertical_shift), Vector2(adjusted_x, drawable_y_position), highlight_color, link_width)
	return adjusted_x

func draw_triangle(aimed_at : Vector2, is_pointing_up : bool) -> int:
	var triangle : PackedVector2Array = []
	triangle.append(aimed_at)
	var vertical_shift = link_width if is_pointing_up else - link_width
	triangle.append(Vector2(aimed_at.x + link_width, aimed_at.y + vertical_shift))
	triangle.append(Vector2(aimed_at.x - link_width, aimed_at.y + vertical_shift))
	draw_polygon(triangle, [highlight_color])
	return vertical_shift

func draw_link_lane(most_left_x_position, most_right_x_position, drawable_y_position):
	draw_line(Vector2(most_left_x_position, drawable_y_position), Vector2(most_right_x_position, drawable_y_position), highlight_color, link_width)

func get_drawable_y_height(key, array_nodes: Array) -> int:
	var potential_y_position = (key.global_position.y + key.size.y + array_nodes[0].global_position.y) / 2
	return get_viable_position(potential_y_position, already_drawn_y, 1)

func get_drawable_x_position(potential_x : int) -> int:
	return get_viable_position(potential_x, already_drawn_x, 1)

func get_viable_position(potential : int, concerned_list : Array[int], iteration : int) -> int:
	if(potential in concerned_list):
		if (iteration % 2 == 0):
			return get_viable_position(potential - 2 * link_width * iteration, concerned_list, iteration + 1)
		else:
			return get_viable_position(potential + 2 * link_width * iteration, concerned_list, iteration + 1)
	else:
		concerned_list.append(potential)
		return potential

func to_link_dictionary(fuseki_link_data) -> Dictionary:
	var links : Dictionary = {} #desination as key -> list 
	for link in fuseki_link_data:
		var source_node = get_node_by_name(link.first_node_name)
		if(not links.has(source_node)):
			links[source_node] = []
		links[source_node].append(get_node_by_name(link.second_node_name))
	return links

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

#Return a position on the middle and bottom of a node
static func get_middle_x(node) -> int:
	var position = node.global_position
	var size = node.size
	return position.x + size.x / 2 - link_width / 2

func get_bottom_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(get_middle_x(node), position.y + size.y)
	return corrected_position

func get_top_side(node) -> Vector2:
	var position = node.global_position
	var size = node.size
	var corrected_position = Vector2(get_middle_x(node), position.y)
	return corrected_position
