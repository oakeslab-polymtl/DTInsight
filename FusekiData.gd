extends Node

var service
var enabler
var model

func inputDataFromFusekiJSON(json):
	var json_head = json["head"]["vars"][0]
	var json_results = json["results"]["bindings"]
	match json_head:
		"service":
			service = json_results
		"enabler":
			enabler = json_results
		"model":
			model = json_results
