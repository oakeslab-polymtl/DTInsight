extends Node

#Sparql queries intended to interact with the Fuseki Server

const SERVICES_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?service a DTDFvocab:Service .
	OPTIONAL {?service ?attribute ?value}
}"

const ENABLERS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?enabler a DTDFvocab:Enabler .
	OPTIONAL {?enabler ?attribute ?value}
}"

const MODELS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?model a DTDFvocab:Model .
	OPTIONAL {?model ?attribute ?value}
}"

const PROVIDED_THINGS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?provided a DTDFvocab:ProvidedThing .
	OPTIONAL {?provided ?attribute ?value}
}"

const DATA_TRANSMITTED_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?dataT a DTDFvocab:DataTransmitted .
	OPTIONAL {?dataT ?attribute ?value}
}"

const SENSORS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?sensor a DTDFvocab:SensingComponent .
	OPTIONAL {?sensor ?attribute ?value}
}"
