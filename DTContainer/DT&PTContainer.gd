extends Control

class_name DT_PT

#Reference each visual data container
@onready var service_container = $DTContainer/ServicesPanel/ServicesContainer
@onready var enabler_container = $DTContainer/EnablersPanel/EnablersContainer
@onready var model_container = $DTContainer/ModelsPanel/ModelsContainer
@onready var insight_container = $PTContainer/PanelContainer/InsightsContainer

#Container side enum
enum ContainerSide {
  TOP,
  BOTTOM,
  ANY
}

#Access to fuseki data
var fuseki_data = null

#Load the generic display scene
const generic_display = preload("res://GenericDisplay/generic_display.tscn")

#Displayes node referenced by its name
class NamedNode:
	var name : String
	var node

#Array of displayes nodes
var displayed_node_list: Array[NamedNode]

#Link width
const link_width : int = 5

#displayed coordinates collection
var already_drawn_x : Array[int] = []
var already_drawn_y : Array[int] = []

#link display colot
const dimmed_color : Color = Color.GRAY
const highlight_color : Color = Color.DIM_GRAY

#name of highlighted element
var highlighted_element = null

#initialization
func _ready():
	GenericDisplaySignals.generic_display_over.connect(_on_element_over)

#set highlighted element on signal
func _on_element_over(element_name):
	if (element_name == ""):
		highlighted_element = null
	else:
		highlighted_element = get_node_by_name(element_name)

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
	update_node_with(insight_container, fuseki_data.insight)

#Update a node with Fuseki element data by creating a generic display node
func update_node_with(visual_container, fuseki_node_data : Dictionary):
	DT_PT.free_all_child(visual_container)
	for key in fuseki_node_data.keys():
		var new_node = generic_display.instantiate()
		new_node.get_node("GenericElementName").text = key
		visual_container.add_child(new_node)
		var displayed_element = NamedNode.new()
		displayed_element.name = key
		displayed_element.node = new_node
		displayed_node_list.append(displayed_element)
		
func _process(_delta):
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
		update_link_with(fuseki_data.enabler_to_service)
		update_link_with(fuseki_data.model_to_enabler)
		update_link_with(fuseki_data.service_to_insight, ContainerSide.TOP)

#With Fuseki link data draw those links
func update_link_with(fuseki_link_data, force_side_source : ContainerSide = ContainerSide.ANY):
	if(fuseki_link_data == null):
		return
	var links_as_dict : Dictionary = to_link_dictionary(fuseki_link_data)
	for key in links_as_dict.keys():
		var drawable_y_position : int = get_drawable_y_position_for_container_side(force_side_source, key, links_as_dict[key])
		var x_drawn_list : Array[int] = []
		var x_highlight_list : Array[int] = []
		var source_in_critical_path : bool = in_critical_path(key, links_as_dict[key])
		var source_color : Color = get_appripriate_link_color(source_in_critical_path)
		var source_x = draw_element_to_lane(key, drawable_y_position, source_color)
		x_drawn_list.append(source_x)
		if(source_in_critical_path):
			x_highlight_list.append(source_x)
		for association_element in links_as_dict[key]:
			var destination_in_critical_path : bool = in_critical_path(key, [association_element])
			var arrow_color : Color = get_appripriate_link_color(destination_in_critical_path)
			var drawn_x : int = draw_element_to_lane(association_element, drawable_y_position, arrow_color, true)
			x_drawn_list.append(drawn_x)
			if(destination_in_critical_path):
				x_highlight_list.append(drawn_x)
		draw_link_lane(x_drawn_list, x_highlight_list, drawable_y_position)

func in_critical_path(source, destinations : Array) -> bool:
	return (highlighted_element == null or source == highlighted_element or highlighted_element in destinations)

func get_appripriate_link_color(is_in_critical_path : bool):
	return highlight_color if is_in_critical_path else dimmed_color

func get_drawable_y_position_for_container_side(side : ContainerSide, key : Object, links : Array) -> int:
	match side :
		ContainerSide.ANY :
			return get_drawable_y_height(key, links)
		ContainerSide.TOP :
			return get_viable_position(get_top_side(key).y - 20 * link_width, already_drawn_y, 1)
		ContainerSide.BOTTOM :
			return get_viable_position(get_bottom_side(key).y + 20 * link_width, already_drawn_y, 1)
	return 0

func draw_element_to_lane(node, drawable_y_position : int, color : Color, destination : bool = false) -> int:
	var is_pointing_up : bool = node.global_position.y < drawable_y_position
	var drawing_position_element : Vector2 = get_bottom_side(node) if (is_pointing_up) else get_top_side(node)
	var adjusted_x : int = get_drawable_x_position(drawing_position_element.x)
	var vertical_shift : int = draw_triangle(Vector2(adjusted_x, drawing_position_element.y), color, is_pointing_up) if destination else 0
	draw_line(Vector2(adjusted_x, drawing_position_element.y + vertical_shift), Vector2(adjusted_x, drawable_y_position), color, link_width)
	return adjusted_x

func draw_triangle(aimed_at : Vector2, color : Color, is_pointing_up : bool) -> int:
	var triangle : PackedVector2Array = []
	triangle.append(aimed_at)
	var vertical_shift = link_width if is_pointing_up else - link_width
	triangle.append(Vector2(aimed_at.x + link_width * 2, aimed_at.y + vertical_shift * 3))
	triangle.append(Vector2(aimed_at.x - link_width * 2, aimed_at.y + vertical_shift * 3))
	draw_polygon(triangle, [color])
	return vertical_shift

func draw_link_lane(x_drawn : Array[int], x_highlight : Array[int], drawable_y_position: int):
	var most_left_x_position : int = x_drawn.min() - round(link_width / 2 - 0.5)
	var most_right_x_position : int = x_drawn.max() + round(link_width / 2 + 0.5)
	var base_color = highlight_color if (highlighted_element == null) else dimmed_color
	draw_line(Vector2(most_left_x_position, drawable_y_position), Vector2(most_right_x_position, drawable_y_position), base_color, link_width)
	if (not x_highlight.is_empty()):
		var most_left_highlight_x_position : int = x_highlight.min() - round(link_width / 2 - 0.5)
		var most_right_highlight_x_position : int = x_highlight.max() + round(link_width / 2 + 0.5)
		draw_line(Vector2(most_left_highlight_x_position, drawable_y_position), Vector2(most_right_highlight_x_position, drawable_y_position), highlight_color, link_width)

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

static func shift_position(initial_position : Vector2, shift_value) -> Vector2:
	return Vector2(initial_position.x + shift_value, initial_position.y)

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
	var node_position = node.global_position
	var node_size = node.size
	return node_position.x + node_size.x / 2 - link_width / 2

func get_bottom_side(node) -> Vector2:
	var node_position = node.global_position
	var node_size = node.size
	var corrected_position = Vector2(DT_PT.get_middle_x(node), node_position.y + node_size.y)
	return corrected_position

func get_top_side(node) -> Vector2:
	var node_position = node.global_position
	var corrected_position = Vector2(DT_PT.get_middle_x(node), node_position.y)
	return corrected_position
