extends Node

const LEGENDS : Dictionary = {
	"Realtime Relationships" : RT_LEGENDS,
	"Component Evolution" : BG_LEGENDS
}

const RT_LEGENDS : Dictionary = {
	"Slower than realtime" : StyleConfig.RTBorder.SLOWER_THAN_RT_COLOR,
	"Realtime" : StyleConfig.RTBorder.RT_COLOR,
	"Faster than realtime" : StyleConfig.RTBorder.FASTER_THAN_RT_COLOR,
}

const BG_LEGENDS : Dictionary = {
	"Implemented": StyleConfig.DTElement.DIMMED_COLOR,
	"Planned": StyleConfig.DTElement.PLANNED_COLOR
}
