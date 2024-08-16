extends Node

const USER : String = "incubator"
const PASS : String = "incubator"
const HOST : String = "localhost"
const PORT : int = 5672

const MESSAGES_LIMIT : int = 100
const MIN_TEMPS_PLOTTED : int = 0
const MAX_TEMPS_PLOTTED : int = 40
const CHART_NULL_VALUE : int = 0

const EXCHANGE_NAME : String = "Incubator_AMQP"
const ROUTING_KEYS : Array[String] = [
	"incubator.record.driver.state"
]

class InfoContainers:
	const T1_CONTAINER : String = "temp_sensor_1"
	const T2_CONTAINER : String = "temp_sensor_2"
	const T3_CONTAINER : String = "temp_sensor_3"
	const HEATER_CONTAINER : String = "fan"
	const FAN_CONTAINER : String = "heater"
