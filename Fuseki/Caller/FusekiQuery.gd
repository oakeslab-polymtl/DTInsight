extends Node

#Sparql queries intended to interact with the Fuseki Server

#Dt/PT objects -------------------------------------------------------------------------------------

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

const DATA_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?data a DTDFvocab:Data .
	OPTIONAL {?data ?attribute ?value}
}"

const SENSORS_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>

SELECT *
WHERE {
	?sensor a DTDFvocab:SensingComponent .
	OPTIONAL {?sensor ?attribute ?value}
}"

const ENV_QUERY = "PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>
PREFIX base:        <https://bentleyjoakes.github.io/DTDF/vocab/base#>

SELECT ?env ?attribute ?value
WHERE {
	?sus a DTDFvocab:SystemUnderStudy .
	?sus DTDFvocab:hasEnvironment ?envS .
	?env base:isContainedIn ?envS .
	OPTIONAL {?env ?attribute ?value}
}"

const SYS_COMPONENT_QUERY ="PREFIX DTDFvocab:   <https://bentleyjoakes.github.io/DTDF/vocab/DTDFVocab#>
PREFIX rdfs:        <http://www.w3.org/2000/01/rdf-schema#>
PREFIX base:        <https://bentleyjoakes.github.io/DTDF/vocab/base#>

SELECT ?sysComponent ?attribute ?value
WHERE {
	?sus a DTDFvocab:SystemUnderStudy .
	?sus DTDFvocab:hasSystem ?sys .
	?sysComponent base:isContainedIn ?sys .
	OPTIONAL {?sysComponent ?attribute ?value}
}"

#Rabbit objects ------------------------------------------------------------------------------------

const RABBIT_EXCHANGE_QUERY = "PREFIX rabbit:		<https://bentleyjoakes.github.io/DTaaS/RabbitMQVocab#>

SELECT ?exc ?attribute ?value
WHERE {
	?exc a rabbit:ExchangeName .
	?exc ?attribute ?value
}"

const RABBIT_ROUTING_KEY_QUERY ="PREFIX rabbit:		<https://bentleyjoakes.github.io/DTaaS/RabbitMQVocab#>

SELECT ?route ?attribute ?value
WHERE {
	?route a rabbit:RoutingKey  .
	?route ?attribute ?value
}"

const RABBIT_SOURCE_QUERY = "PREFIX rabbit:		<https://bentleyjoakes.github.io/DTaaS/RabbitMQVocab#>

SELECT ?source ?attribute ?value
WHERE {
	?source a rabbit:Source  .
	?source ?attribute ?value
}"

const RABBIT_MESSAGE_LISTENER_QUERY = "PREFIX rabbit:		<https://bentleyjoakes.github.io/DTaaS/RabbitMQVocab#>

SELECT ?ml ?attribute ?value
WHERE {
	?ml a rabbit:MessageListener   .
	?ml ?attribute ?value
}"
