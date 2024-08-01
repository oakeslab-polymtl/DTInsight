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
	const DATA = "data"
	const PROVIDED = "provided"
	const SENSOR = "sensor"
	const ENV = "env"
	const SYSTEM_COMPONENT = "sysComponent"

class RelationAttribute:
	const MODEL_TO_ENABLER = "inputTo"
	const ENABLER_TO_SERVICE = "enables"
	const SERVICES_TO_PROVIDED = "provides"
	const SENSOR_TO_DATA_TRANSMITTED = "producedFrom"
	const DATA_TO_ENABLER = "inputTo"
	const DATA_TRANSMITTED_TO_DATA = "fromData"
