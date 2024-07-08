extends Node

class GenericElement:
	var element_name : String
	var element_attributes : Dictionary

class GenericLinkedNodes:
	var first_node_name: String
	var second_node_name: String

class JsonValue:
	var json_name: String
	var json_value : String

var service
var service_to_enabler
var enabler_to_service
var enabler
var model

func inputDataFromFusekiJSON(json):
	var json_head = json["head"]["vars"]
	if ("service" in json_head && "enabler" in json_head):
		if (json_head[0] == "service"):
			service_to_enabler = parse_fuseki_json(json, true)
		else:
			enabler_to_service = parse_fuseki_json(json, true)
	elif ("service" in json_head):
		service = parse_fuseki_json(json)
	elif("enabler" in json_head):
		enabler = parse_fuseki_json(json)
	elif ("model" in json_head):
		model = parse_fuseki_json(json)

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

func parse_fuseki_value(value) -> String:
	if(value.contains("#")):
		return value.split("#")[1]
	return value

func format_result(result_aggregator, is_link = false):
	var formated_result = []
	for result in result_aggregator:
		if(result.size() <= 0):
			break
		elif(is_link):
			var link = GenericLinkedNodes.new()
			link.first_node_name = result[0].json_value
			link.second_node_name = result[1].json_value
			formated_result.append(link)
		else:
			var element = GenericElement.new()
			element.element_name = result[0].json_value
			for i in range(1, result.size()):
				element.element_attributes[result[i].json_name] = result[i].json_value
			formated_result.append(element)
	return formated_result
