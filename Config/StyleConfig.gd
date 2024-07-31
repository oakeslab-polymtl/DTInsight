extends Node

#Realtime relationship style
class RTBorder:
	const BORDER_WIDTH : int = 5

	const SLOWER_THAN_RT_COLOR : Color = Color.BLUE_VIOLET
	const RT_COLOR : Color = Color.AQUAMARINE
	const FASTER_THAN_RT_COLOR : Color = Color.GOLD

#DT/RT displayed element style
class DTElement:
	const DIMMED_COLOR : Color = Color.GRAY
	const HIGHLIGHT_COLOR : Color = Color.DIM_GRAY

#Visual link style
class Link:
	const WIDTH : int = 5
	
	const MEAN_OUTER_LINK_DISTANCE : int = 30 * WIDTH
	
	const DIMMED_COLOR : Color = Color.GRAY
	const HIGHLIGHT_COLOR : Color = Color.DIM_GRAY

#Legends style
class Legends:
	const GO_AWAY_TEXT : String = "VVV"
	const COME_IN_TEXT : String = "ΛΛΛ"
	
	const RETRACT_BUTTON_COLOR : Color = Color.DARK_ORANGE
	const PANEL_COLOR : Color = Color.GRAY
	const CATEGORY_ANNONCE_COLOR : Color = Color.DIM_GRAY
