extends Node

#Fuseki endpoint data
class Connection:
	const URL = "http://localhost:3030" #Fuseki server, localhost if started from openCAESAR on this machine
	const DATASET = "/DTDF" #FUseki endpoint defined in fuseki.ttl in the project
	const ENDPOINT = "/sparql?query=" #sparql endpoint

#JSON match
class JsonHead:
	const SERVICE = "service"
	const ENABLER = "enabler"
	const MODEL = "model"
	const DATA_TRANSMITTED = "dataT"
	const PROVIDED = "provided"
	const SENSOR = "sensor"

class RelationAttribute:
	const MODEL_TO_ENABLER = "inputTo"
	const ENABLER_TO_SERVICE = "enables"
	const SERVICES_TO_PROVIDED = "provides"
