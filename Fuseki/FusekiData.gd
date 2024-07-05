extends Node

class LinkedNodes:
	var first_node
	var second_node

var service
var service_to_enabler
var enabler
var model

func inputDataFromFusekiJSON(json):
	var json_head = json["head"]["vars"]
	match json_head:
		["service"]:
			service = parse_fuseki_json(json)
		["service", "enabler"]:
			service_to_enabler = parse_fuseki_json(json)
		["enabler"]:
			enabler = parse_fuseki_json(json)
		["model"]:
			model = parse_fuseki_json(json)

func parse_fuseki_json(json):
	var json_head = json["head"]["vars"]
	var json_results = json["results"]["bindings"]
	var result_aggregator: = []
	for result in json_results:
		if (result == null):
			break
		var tuple_aggregator = []
		for head in json_head:
			tuple_aggregator.append(parse_fuseki_value(result[head]["value"]))
		result_aggregator.append(tuple_aggregator)
	return format_result(result_aggregator)

func parse_fuseki_value(value) -> String:
	return value.split("#")[1]

func format_result(result_aggregator):
	var formated_result = []
	for result in result_aggregator:
		if(result.size() <= 0):
			break
		elif (result.size() == 1):
			formated_result.append(result[0])
		else:
			var link = LinkedNodes.new()
			link.first_node = result[0]
			link.second_node = result[1]
			formated_result.append(link)
	return formated_result
