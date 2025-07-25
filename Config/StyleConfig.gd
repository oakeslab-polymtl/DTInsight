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
	const TEXT_HIGHLIGHT_COLOR : Color = Color.WHITE_SMOKE
	const PLANNED_COLOR : Color = Color(Color.WHITE, 0.6)

#Visual link style
class Link:
	const WIDTH : int = 5
	
	const MEAN_OUTER_LINK_DISTANCE : int = 15 * WIDTH
	
	const DIMMED_COLOR : Color = Color.GRAY
	const HIGHLIGHT_COLOR : Color = Color.DIM_GRAY

#Legends style
class Legends:
	const GO_AWAY_TEXT : String = "Hide legend"
	const COME_IN_TEXT : String = "Show legend"
	
	const RETRACT_BUTTON_COLOR : Color = Color.DARK_ORANGE
	const PANEL_COLOR : Color = Color.DARK_GRAY
	const CATEGORY_ANNONCE_COLOR : Color = Color(0.3, 0.3, 0.3)
