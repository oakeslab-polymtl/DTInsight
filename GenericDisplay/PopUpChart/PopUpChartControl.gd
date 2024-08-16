extends Control

class_name ChartControl

@onready var chart: Chart = $VBoxContainer/ChartContainer/Chart

var up_to_date : bool = false
var current_step : int = RabbitConfig.MESSAGES_LIMIT

# This Chart will plot 3 different functions
var f1: Function

func _ready():
	ChartSignals.new_chart_value.connect(add_value)
	ChartSignals.hide.connect(hide_pop_up)
	reset()

func hide_pop_up() -> void:
	reset()

func add_value(value : int) -> void:
	current_step += 1
	f1.remove_point(0)
	f1.add_point(current_step, value)
	chart.queue_redraw() # This will force the Chart to be updated

func feed_historic(historic : Array) -> void:
	print(historic)
	for element in historic:
		add_value(element)
	up_to_date = true

func reset():
	up_to_date = false
	
	var x: PackedFloat32Array = range(0, RabbitConfig.MESSAGES_LIMIT)
	
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
	var zeros_array = []
	for i in range(RabbitConfig.MESSAGES_LIMIT):
		zeros_array.append(RabbitConfig.CHART_NULL_VALUE)
	var y: Array = zeros_array
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.colors.frame = Color("#161a1d")
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color("#283442")
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.title = "Realtime Monitoring"
	cp.x_label = "Time"
	cp.y_label = "Values"
	cp.x_scale = 5
	cp.y_scale = 10
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Let's add values to our functions
	f1 = Function.new(
		x, y, "Value", # This will create a function with x and y values taken by the Arrays 
						# we have created previously. This function will also be named "Pressure"
						# as it contains 'pressure' values.
						# If set, the name of a function will be used both in the Legend
						# (if enabled thourgh ChartProperties) and on the Tooltip (if enabled).
		# Let's also provide a dictionary of configuration parameters for this specific function.
		{ 
			color = Color("#36a2eb"), 		# The color associated to this function
			marker = Function.Marker.CIRCLE, 	# The marker that will be displayed for each drawn point (x,y)
											# since it is `NONE`, no marker will be shown.
			type = Function.Type.LINE, 		# This defines what kind of plotting will be used, 
											# in this case it will be a Linear Chart.
			interpolation = Function.Interpolation.STAIR	# Interpolation mode, only used for 
															# Line Charts and Area Charts.
		}
	)
	
	# Now let's plot our data
	chart.plot([f1], cp)


func _on_hide_button_pressed() -> void:
	ChartSignals.hide.emit()
