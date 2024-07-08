extends Button

@onready var SparqlRequest = $SparqlFusekiQueries
@onready var FusekiDataManager = $SparqlFusekiQueries/FusekiData
@onready var FusekiQueryManager = $SparqlFusekiQueries/FusekiQuery

signal fuseki_data_updated

const URL = "http://localhost:3030" #Fuseki server, localhost if started from openCAESAR on this machine
const DATASET = "/DTDF" #FUseki endpoint defined in fuseki.ttl in the project
const ENDPOINT = "/sparql?query=" #sparql endpoint

func _on_pressed():
	query_fuseky(FusekiQueryManager.SERVICES_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.ENABLERS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.MODELS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.SERVICES_TO_ENABLERS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.ENABLERS_TO_SERVICES_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(FusekiQueryManager.MODELS_TO_ENABLERS_QUERY)
	await(SparqlRequest.request_completed)
	fuseki_data_updated.emit()
	
func query_fuseky(query):
	SparqlRequest.request(URL + DATASET + ENDPOINT + query.uri_encode())

func _on_fuseki_completion(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	FusekiDataManager.inputDataFromFusekiJSON(json)
