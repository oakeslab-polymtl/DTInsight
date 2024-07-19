extends Node

#Sparql queries intended to interact with the Fuseki Server

const SERVICES_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?service a DTDFvocab:Service .
	OPTIONAL {?service ?attribute ?value}
}"

const ENABLERS_TO_SERVICES_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?enabler a DTDFvocab:Enabler .
	?enabler DTDFvocab:enables ?service
}"

const ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?enabler a DTDFvocab:Enabler .
	OPTIONAL {?enabler ?attribute ?value}
}"

const MODELS_TO_ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?model a DTDFvocab:Model .
	?model DTDFvocab:inputTo ?enabler
}"

const MODELS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?model a DTDFvocab:Model .
	OPTIONAL {?model ?attribute ?value}
}"

const INSIGHTS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?insight a DTDFvocab:Insight .
	OPTIONAL {?insight ?attribute ?value}
}"

const SERVICES_TO_INSIGHTS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?service a DTDFvocab:Service .
	?service DTDFvocab:provides ?insight
}"
