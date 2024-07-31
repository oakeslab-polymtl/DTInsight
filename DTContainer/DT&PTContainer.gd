extends Control

class_name DT_PT

#Reference each visual data container
@onready var service_container = $DTContainer/ServicesPanel/ServicesContainer
@onready var enabler_container = $DTContainer/EnablersPanel/EnablersContainer
@onready var model_container = $DTContainer/ModelsPanel/ModelsContainer
@onready var operator_container = $"PTContainer/Operator&EnvContainer/OperatorPanel/OperatorContainer"
@onready var machine_container = $PTContainer/DataTravelContainer/MachinePanel/MachineContainer
@onready var data_transmitted_container = $PTContainer/DataTravelContainer/DataTransmittedPanel/DataTransmittedContainer

#Container side enum
enum ContainerSide {
  TOP,
  BOTTOM,
  ANY
}

#Access to fuseki data
var fuseki_data : FusekiData = null

#Load the generic display scene
const GenericDisplay = preload("res://GenericDisplay/generic_display.tscn")

#Displayes node referenced by its name
class NamedNode:
	var name : String
	var node : GenericDisplay

#Array of displayes nodes
var displayed_node_list: Array[NamedNode]

#displayed coordinates collection
var already_drawn_x : Array[int] = []
var already_drawn_y : Array[int] = []

#name of highlighted element
var highlighted_element = null

#attributes
const border_attribute : String = "hasTimeScale"
const type_attribute : String = "type"

#Operator/machine
const opperator_type : String = "Insight"

#initialization
func _ready():
	GenericDisplaySignals.generic_display_over.connect(_on_element_over)

#set highlighted element on signal
func _on_element_over(element_name):
	if (element_name == ""):
		highlighted_element = null
		GenericDisplaySignals.generic_display_highlight.emit([])
	else:
		highlighted_element = get_node_by_name(element_name)
		GenericDisplaySignals.generic_display_highlight.emit(get_all_connected_to(element_name))

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
	update_provided_things(operator_container, machine_container, fuseki_data.provided_thing)
	update_node_with(data_transmitted_container, fuseki_data.data_transmitted)

func update_provided_things(operator_container : HBoxContainer, machine_container : HBoxContainer, provided_data : Dictionary):
	var operator_data : Dictionary = {}
	var machine_data : Dictionary = {}
	for entry_name in provided_data.keys():
		if (type_attribute in provided_data[entry_name].keys()):
			if (opperator_type in provided_data[entry_name][type_attribute]):
				operator_data[entry_name] = provided_data[entry_name]
			else:
				machine_data[entry_name] = provided_data[entry_name]
	update_node_with(operator_container, operator_data)
	update_node_with(machine_container, machine_data)

#Update a node with Fuseki element data by creating a generic display node
func update_node_with(visual_container : HBoxContainer, fuseki_node_data : Dictionary):
	DT_PT.free_all_child(visual_container)
	for key in fuseki_node_data.keys():
		var new_node = GenericDisplay.instantiate()
		new_node.set_text(key)
		visual_container.add_child(new_node)
		var displayed_element = NamedNode.new()
		displayed_element.name = key
		displayed_element.node = new_node
		displayed_node_list.append(displayed_element)
		set_starting_node_style(displayed_element, fuseki_node_data[key])

func set_starting_node_style(namedNode : NamedNode, attributes : Dictionary):
	namedNode.node.set_dimmed_style()
	if (border_attribute in attributes.keys()):
		match attributes[border_attribute]:
			["slower_trt"]:
				namedNode.node.set_slower_style()
			["rt"]:
				namedNode.node.set_rt_style()
			["faster_trt"]:
				namedNode.node.set_faster_style()

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

func get_all_connected_to(element_name : String) -> Array[String]:
	var all_connected : Array[String]= [element_name]
	for link in fuseki_data.enabler_to_service + fuseki_data.model_to_enabler + fuseki_data.service_to_provided_thing:
		if link.first_node_name == element_name:
			all_connected.append(link.second_node_name)
		if link.second_node_name == element_name:
			all_connected.append(link.first_node_name)
	return all_connected

#Draw all links
func _draw():
	if (not fuseki_data == null):
		update_link_with(fuseki_data.enabler_to_service)
		update_link_with(fuseki_data.model_to_enabler)
		update_link_with(fuseki_data.service_to_provided_thing, ContainerSide.TOP)

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
	return StyleConfig.Link.HIGHLIGHT_COLOR if is_in_critical_path else StyleConfig.Link.DIMMED_COLOR

func get_drawable_y_position_for_container_side(side : ContainerSide, key : Object, links : Array) -> int:
	match side :
		ContainerSide.ANY :
			return get_drawable_y_height(key, links)
		ContainerSide.TOP :
			return get_viable_position(get_top_side(key).y - 20 * StyleConfig.Link.WIDTH, already_drawn_y, 1)
		ContainerSide.BOTTOM :
			return get_viable_position(get_bottom_side(key).y + 20 * StyleConfig.Link.WIDTH, already_drawn_y, 1)
	return 0

func draw_element_to_lane(node, drawable_y_position : int, color : Color, destination : bool = false) -> int:
	var is_pointing_up : bool = node.global_position.y < drawable_y_position
	var drawing_position_element : Vector2 = get_bottom_side(node) if (is_pointing_up) else get_top_side(node)
	var adjusted_x : int = get_drawable_x_position(drawing_position_element.x)
	var vertical_shift : int = draw_triangle(Vector2(adjusted_x, drawing_position_element.y), color, is_pointing_up) if destination else 0
	draw_line(Vector2(adjusted_x, drawing_position_element.y + vertical_shift), Vector2(adjusted_x, drawable_y_position), color, StyleConfig.Link.WIDTH)
	return adjusted_x

func draw_triangle(aimed_at : Vector2, color : Color, is_pointing_up : bool) -> int:
	var triangle : PackedVector2Array = []
	triangle.append(aimed_at)
	var vertical_shift = StyleConfig.Link.WIDTH if is_pointing_up else - StyleConfig.Link.WIDTH
	triangle.append(Vector2(aimed_at.x + StyleConfig.Link.WIDTH * 2, aimed_at.y + vertical_shift * 3))
	triangle.append(Vector2(aimed_at.x - StyleConfig.Link.WIDTH * 2, aimed_at.y + vertical_shift * 3))
	draw_polygon(triangle, [color])
	return vertical_shift

func draw_link_lane(x_drawn : Array[int], x_highlight : Array[int], drawable_y_position: int):
	var most_left_x_position : int = x_drawn.min() - round(StyleConfig.Link.WIDTH / 2 - 0.5)
	var most_right_x_position : int = x_drawn.max() + round(StyleConfig.Link.WIDTH / 2 + 0.5)
	var base_color = StyleConfig.Link.HIGHLIGHT_COLOR if (highlighted_element == null) else StyleConfig.Link.DIMMED_COLOR
	draw_line(Vector2(most_left_x_position, drawable_y_position), Vector2(most_right_x_position, drawable_y_position), base_color, StyleConfig.Link.WIDTH)
	if (not x_highlight.is_empty()):
		var most_left_highlight_x_position : int = x_highlight.min() - round(StyleConfig.Link.WIDTH / 2 - 0.5)
		var most_right_highlight_x_position : int = x_highlight.max() + round(StyleConfig.Link.WIDTH / 2 + 0.5)
		draw_line(Vector2(most_left_highlight_x_position, drawable_y_position), Vector2(most_right_highlight_x_position, drawable_y_position), StyleConfig.Link.HIGHLIGHT_COLOR, StyleConfig.Link.WIDTH)

func get_drawable_y_height(key, array_nodes: Array) -> int:
	var potential_y_position = (key.global_position.y + key.size.y + array_nodes[0].global_position.y) / 2
	return get_viable_position(potential_y_position, already_drawn_y, 1)

func get_drawable_x_position(potential_x : int) -> int:
	return get_viable_position(potential_x, already_drawn_x, 1)

func get_viable_position(potential : int, concerned_list : Array[int], iteration : int) -> int:
	if(potential in concerned_list):
		if (iteration % 2 == 0):
			return get_viable_position(potential - 2 * StyleConfig.Link.WIDTH * iteration, concerned_list, iteration + 1)
		else:
			return get_viable_position(potential + 2 * StyleConfig.Link.WIDTH * iteration, concerned_list, iteration + 1)
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
	return node_position.x + node_size.x / 2 - StyleConfig.Link.WIDTH / 2

func get_bottom_side(node) -> Vector2:
	var node_position = node.global_position
	var node_size = node.size
	var corrected_position = Vector2(DT_PT.get_middle_x(node), node_position.y + node_size.y)
	return corrected_position

func get_top_side(node) -> Vector2:
	var node_position = node.global_position
	var corrected_position = Vector2(DT_PT.get_middle_x(node), node_position.y)
	return corrected_position
