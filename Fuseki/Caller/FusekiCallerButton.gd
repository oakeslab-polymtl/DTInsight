extends Button

@onready var SparqlRequest = $SparqlFusekiQueries
@onready var FusekiQueryManager = $SparqlFusekiQueries/FusekiQuery

#FusekiDataManager
var FusekiDataManager : FusekiData
func set_fuseki_data_manager(fuseki_data_manager : FusekiData):
	FusekiDataManager = fuseki_data_manager

#On pressed call all queries and emit a signal
func _on_pressed():
	disabled = true
	query_fuseky(FusekiQueryManager.SERVICES_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.ENABLERS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.MODELS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.DATA_TRANSMITTED_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.PROVIDED_THINGS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.SENSORS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.ENV_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.SYS_COMPONENT_QUERY)
	await(SparqlRequest.request_completed)
	FusekiSignals.fuseki_data_updated.emit()
	disabled = false

#Query the Fuseki Server with a given query
func query_fuseky(query):
	SparqlRequest.request(FusekiConfig.Connection.URL + FusekiConfig.Connection.DATASET + FusekiConfig.Connection.ENDPOINT + query.uri_encode())

#Parse and store resulting Fuseki json
func _on_fuseki_completion(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	FusekiDataManager.input_data_from_fuseki_JSON(json)
