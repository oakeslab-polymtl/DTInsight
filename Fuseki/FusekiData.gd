extends Node

#Represent a link between two elements by their names
class GenericLinkedNodes:
	var first_node_name: String
	var second_node_name: String

#Internal data stucture
class JsonValue:
	var json_name: String
	var json_value : String

#Store parsed values from Fuseki
var service : Dictionary
var service_to_enabler : Array[GenericLinkedNodes]
var enabler_to_service : Array[GenericLinkedNodes]
var enabler : Dictionary
var model_to_enabler : Array[GenericLinkedNodes]
var model : Dictionary

#Teke a json from a Fuseki query and store the resulting informations in 
#variables reachable from the Godot application
func inputDataFromFusekiJSON(json):
	var json_head = json["head"]["vars"]
	if ("service" in json_head && "enabler" in json_head):
		if (json_head[0] == "service"):
			service_to_enabler = parse_fuseki_json(json, true)
		else:
			enabler_to_service = parse_fuseki_json(json, true)
	elif ("model" in json_head && "enabler" in json_head):
		model_to_enabler = parse_fuseki_json(json, true)
	elif ("service" in json_head):
		service = parse_fuseki_json(json)
	elif("enabler" in json_head):
		enabler = parse_fuseki_json(json)
	elif ("model" in json_head):
		model = parse_fuseki_json(json)

#Parse the json from Fuseki into internal data structure
#Return an Array of GenericLinkedNodes or a Dictionary depending on the data type
func parse_fuseki_json(json, is_link = false):
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
func parse_fuseki_value(value) -> String:
	if(value.contains("#")):
		return value.split("#")[1]
	return value

#Transform the result agregator in an array of GenericLinkedNodes or
#in a dictionary depending on the data type
func format_result(result_aggregator, is_link = false):
	if(is_link):
		return parse_link_result(result_aggregator)
	else:
		return parse_element_result(result_aggregator)

#Transform the result agregator in an Array of GenericLinkedNodes
func parse_link_result(result_agregator) -> Array[GenericLinkedNodes]:
	var formated_result : Array[GenericLinkedNodes] = []
	for result in result_agregator:
		var link = GenericLinkedNodes.new()
		link.first_node_name = result[0].json_value
		link.second_node_name = result[1].json_value
		formated_result.append(link)
	return formated_result

#Transfrom the result agregator in a dictionary, in each entry corresponding 
#to an elementis a disctionary containing every attributes of this element
func parse_element_result(result_agregator) -> Dictionary:
	var formated_result : Dictionary = {}
	for result in result_agregator:
		var entry_name = result[0].json_value
		var entry_value : Dictionary = {}
		entry_value[result[1].json_value] = result[2].json_value
		if (formated_result.has(entry_name)):
			formated_result[entry_name].merge(entry_value)
		else :
			formated_result[entry_name] = entry_value
	return formated_result
