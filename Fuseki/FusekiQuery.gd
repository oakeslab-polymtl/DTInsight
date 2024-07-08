extends Node

const SERVICES_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?service
WHERE {
	?service a DTDFvocab:Service
}
GROUP BY ?service"

const SERVICES_TO_ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?service a DTDFvocab:Service .
	?service DTDFvocab:provides ?enabler
}"

const ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?enabler a DTDFvocab:Enabler .
	OPTIONAL {?enabler DTDFvocab:IsAutomatic ?automatic}
}"

const MODELS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?model
WHERE {
	?model a DTDFvocab:Model
}
GROUP BY ?model"
