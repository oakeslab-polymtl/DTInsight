extends Button

@onready var sparql_request = $SparqlFusekiQueries
@onready var fuseki_query_manager = $SparqlFusekiQueries/FusekiQuery

var fuseki_data_manager: FusekiData

func set_fuseki_data_manager(manager: FusekiData) -> void:
	fuseki_data_manager = manager

func _on_pressed() -> void:
	FusekiSignals.fuseki_data_clear.emit()
	disabled = true

	for query_name in fuseki_query_manager.QUERIES.keys():
		var query = fuseki_query_manager.QUERIES[query_name]
		_send_query(query)
		await sparql_request.request_completed

	FusekiSignals.fuseki_data_updated.emit()
	disabled = false

func _send_query(query: String) -> void:
	sparql_request.request(FusekiConfig.URL + FusekiConfig.DATASET + FusekiConfig.ENDPOINT + query.uri_encode())

func _on_fuseki_completion(_result, _response_code, _headers, body) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	fuseki_data_manager.input_data_from_fuseki_JSON(json)
