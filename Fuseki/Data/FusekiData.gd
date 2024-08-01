extends Node

class_name FusekiData

#Represent a link between two elements by their names
class GenericLinkedNodes:
	var source: String
	var destination: String

#Internal data stucture
class JsonValue:
	var json_name: String
	var json_value : String

#Store parsed values from Fuseki
var service : Dictionary
var enabler : Dictionary
var model : Dictionary
var provided_thing : Dictionary
var data_transmitted : Dictionary
var sensing_component : Dictionary
var service_to_provided_thing : Array[GenericLinkedNodes]
var enabler_to_service : Array[GenericLinkedNodes]
var model_to_enabler : Array[GenericLinkedNodes]

func _ready():
	FusekiSignals.fuseki_data_updated.connect(_on_data_updated)

func _on_data_updated():
	build_relations()

#Teke a json from a Fuseki query and store the resulting informations in 
#variables reachable from the Godot application
func input_data_from_fuseki_JSON(json):
	if(not json["head"]["vars"].size() == 3):
		print("Incorrect JSON head : shoulb be [\"<variable>\",\"attribute\",\"value\"]")
		return
	var json_variable : String = json["head"]["vars"][0]
	match json_variable:
		FusekiConfig.JsonHead.SERVICE:
			service = parse_fuseki_json(json)
		FusekiConfig.JsonHead.ENABLER:
			enabler = parse_fuseki_json(json)
		FusekiConfig.JsonHead.MODEL:
			model = parse_fuseki_json(json)
		FusekiConfig.JsonHead.DATA_TRANSMITTED:
			data_transmitted = parse_fuseki_json(json)
		FusekiConfig.JsonHead.PROVIDED:
			provided_thing = parse_fuseki_json(json)
		FusekiConfig.JsonHead.SENSOR:
			sensing_component = parse_fuseki_json(json)

#Parse the json from Fuseki into internal data structure
#Return an Array of GenericLinkedNodes or a Dictionary depending on the data type
static func parse_fuseki_json(json, is_link = false):
	var json_head = json["head"]["vars"]
	var json_results = json["results"]["bindings"]
	var result_aggregator: = []
	for result in json_results:
		if (result == null):
			break
		var tuple_aggregator = []
		for head in json_head:
			if (result.has(head)):
				var new_json_value = JsonValue.new()
				new_json_value.json_name = head
				new_json_value.json_value = parse_fuseki_value(result[head]["value"])
				tuple_aggregator.append(new_json_value)
		result_aggregator.append(tuple_aggregator)
	var formated_result = format_result(result_aggregator, is_link)
	return formated_result

#Remove oml link data from values
static func parse_fuseki_value(value) -> String:
	if(value.contains("#")):
		return value.split("#")[1]
	return value

#Transform the result agregator in an array of GenericLinkedNodes or
#in a dictionary depending on the data type
static func format_result(result_aggregator, is_link = false):
		return parse_link_result(result_aggregator) if (is_link) else parse_element_result(result_aggregator)

#Transform the result agregator in an Array of GenericLinkedNodes
static func parse_link_result(result_agregator) -> Array[GenericLinkedNodes]:
	var formated_result : Array[GenericLinkedNodes] = []
	for result in result_agregator:
		var link = GenericLinkedNodes.new()
		link.first_node_name = result[0].json_value
		link.second_node_name = result[1].json_value
		formated_result.append(link)
	return formated_result

#Transfrom the result agregator in a dictionary, in each entry corresponding 
#to an elementis a disctionary containing every attributes of this element
static func parse_element_result(result_agregator) -> Dictionary:
	var formated_result : Dictionary = {}
	for result in result_agregator:
		var entry_name = result[0].json_value
		if (not formated_result.has(entry_name)):
			formated_result[entry_name] = {}
		var attribute_name = result[1].json_value
		var attribute_value = result[2].json_value
		if attribute_name in formated_result[entry_name].keys() :
			formated_result[entry_name][attribute_name].append(attribute_value)
		else:
			var entry_value : Dictionary = {}
			entry_value[attribute_name] = [attribute_value]
			formated_result[entry_name].merge(entry_value)
	return formated_result

func build_relations():
	model_to_enabler = build_relations_from(model, FusekiConfig.RelationAttribute.MODEL_TO_ENABLER)
	enabler_to_service = build_relations_from(enabler, FusekiConfig.RelationAttribute.ENABLER_TO_SERVICE)
	service_to_provided_thing = build_relations_from(service, FusekiConfig.RelationAttribute.SERVICES_TO_PROVIDED)

func build_relations_from(element_data : Dictionary, link_attribute : String, inversed : bool = false) -> Array[GenericLinkedNodes]:
	var resulting_relations : Array[GenericLinkedNodes] = []
	for element_name in element_data.keys():
		var relation_list : Array = element_data[element_name][link_attribute]
		for linked_name in relation_list:
			var new_relation : GenericLinkedNodes = GenericLinkedNodes.new()
			new_relation.source = element_name if (not inversed) else linked_name
			new_relation.destination = linked_name if (not inversed) else element_name
			resulting_relations.append(new_relation)
	return resulting_relations

func dump(dump_path : String, to_console : bool = false):
	FusekiDataDumper.dump(self, dump_path, to_console)

func empty():
	service = {}
	enabler = {}
	model = {}
	provided_thing = {}
	service_to_provided_thing = []
	enabler_to_service = []
	model_to_enabler = []
