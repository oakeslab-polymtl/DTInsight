extends Node

const USER : String = "incubator"
const PASS : String = "incubator"
const HOST : String = "localhost"
const PORT : int = 5672

const EXCHANGE_NAME : String = "Incubator_AMQP"
const ROUTING_KEYS : Array[String] = [
	"incubator.record.kalmanfilter.plant.state",
	"incubator.record.driver.state"
]

const MESSAGES_LIMIT : int = 10

class InfoContainers:
	const T1_CONTAINER : String = "temp_sensor_1"
	const T2_CONTAINER : String = "temp_sensor_2"
	const T3_CONTAINER : String = "temp_sensor_3"
	const HEATER_CONTAINER : String = "fan"
	const FAN_CONTAINER : String = "heater"

