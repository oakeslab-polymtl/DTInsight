extends Button

@onready var SparqlRequest = $SparqlFusekiQueries

signal services_updated
signal enablers_updated
signal models_updated

var services
var enablers
var models

const URL = "http://localhost:3030" #Fuseki server, localhost if started from openCAESAR on this machine
const DATASET = "/DTDF" #FUseki endpoint defined in fuseki.ttl in the project
const ENDPOINT = "/sparql?query=" #sparql endpoint

const SERVICES_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?service
WHERE {
	?service a DTDFvocab:Service
}
GROUP BY ?service"

const ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?enabler
WHERE {
	?enabler a DTDFvocab:Enabler
}
GROUP BY ?enabler"

const MODELS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?model
WHERE {
	?model a DTDFvocab:Model
}
GROUP BY ?model"

func _on_pressed():
	query_fuseky(SERVICES_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(ENABLERS_QUERY)
	await(SparqlRequest.request_completed)
	query_fuseky(MODELS_QUERY)

func query_fuseky(query):
	SparqlRequest.request(URL + DATASET + ENDPOINT + query.uri_encode())

func _on_fuseki_completion(_result, _response_code, _headers, body):
	#print(body.get_string_from_utf8())
	var json = JSON.parse_string(body.get_string_from_utf8())
	var json_head = json["head"]["vars"][0]
	var json_results = json["results"]["bindings"]
	match json_head:
		"service":
			services = json_results
			services_updated.emit()
		"enabler":
			enablers = json_results
			enablers_updated.emit()
		"model":
			models = json_results
			models_updated.emit()
