extends Camera2D

signal cam_zoom_in
signal cam_zoom_out

# ZOOM

@export var speed_min_zoom := 40
@export var speed_max_zoom := 6

var min_zoom := 0.02
var max_zoom := 40
var start_zoom := min_zoom * 2
var _zoom_level := start_zoom

var zoom_factor := 0.01
var zoom_duration := 0.3
var zoom_key_down_slowdown := 0.1


# PAN

@export var pan_speed_max_zoom := 0.00001
@export var pan_speed_min_zoom := 30
var pan_velocity_ratio := 0.06

# BOUNDS
@export var bound_margin := -40

var camera_bounds := Rect2()

# VELOCITY

var cam_velocity := Vector2()
var cam_slowdown := 0.9

func _ready():
	connect("cam_zoom_in", self._on_cam_zoom_in)
	connect("cam_zoom_out", self._on_cam_zoom_out)
	
	#self.zoom = Vector2(_zoom_level, _zoom_level)

func _process(delta):

	#motion = Vector2(0,0)

	var input = Vector2(0,0)

	if Input.is_action_pressed("cam_move_left"):
		input += Vector2(-1, 0)
	if Input.is_action_pressed("cam_move_right"):
		input += Vector2(1, 0)
	if Input.is_action_pressed("cam_move_down"):
		input += Vector2(0, 1)
	if Input.is_action_pressed("cam_move_up"):
		input += Vector2(0, -1)

	if input.length() > 0:
		
		var ratio = inverse_lerp(min_zoom, max_zoom, _zoom_level)
		#print(ratio)
		var curr_speed = lerpf(speed_min_zoom, speed_max_zoom, ratio)
		#print(curr_speed)

		input = input.normalized()
		cam_velocity += Vector2(input.x, input.y) * curr_speed * delta

	if not cam_velocity.is_zero_approx():
		move()
		
	if Input.is_action_pressed("cam_zoom_in"):
		self._on_cam_zoom_in(true)
	if Input.is_action_pressed("cam_zoom_out"):
		self._on_cam_zoom_out(true)
			
func _unhandled_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT:
		var ratio = inverse_lerp(min_zoom, max_zoom, _zoom_level)
		var curr_speed = lerpf(pan_speed_min_zoom, pan_speed_max_zoom, ratio)
		
		var change = (event as InputEventMouseMotion).relative * curr_speed
		
		cam_velocity -= change * pan_velocity_ratio
		
	if event.is_action_pressed("cam_zoom_in"):
		self._on_cam_zoom_in(false)
	if event.is_action_pressed("cam_zoom_out"):
		self._on_cam_zoom_out(false)
		


func move() -> void:
	#cam_velocity = cam_velocity.normalized()
	self.translate(cam_velocity)
	cam_velocity *= cam_slowdown

	#if self.camera_bounds != Rect2():
		#self.bound_camera()

func snap_to_middle(rect: Rect2) -> void:
	self.position = rect.position + rect.size/2

func set_bounds(rect: Rect2) -> void:
	self.camera_bounds = rect.grow(self.bound_margin)

func bound_camera() -> void:
	self.global_position.x = clamp(self.global_position.x,
		self.camera_bounds.position.x, self.camera_bounds.end.x)
	self.global_position.y = clamp(self.global_position.y,
		self.camera_bounds.position.y, self.camera_bounds.end.y)

	
func _set_zoom_level(value: float):
	_zoom_level = clamp(value, min_zoom, max_zoom)

	var cam_tween := self.create_tween().set_parallel()

	var cursor_camera_position :=  self.position - get_global_mouse_position()
	var delta_offset := cursor_camera_position * (1 - _zoom_level / self.zoom.x)
	var towards_pos := self.position + delta_offset

	cam_tween.tween_property(self, "position", towards_pos, zoom_duration)

	cam_tween.tween_property(self, "zoom", Vector2(_zoom_level, _zoom_level), zoom_duration)# \
		#.set_trans(Tween.TRANS_SINE) \
		#.set_ease(Tween.EASE_OUT)


func _on_cam_zoom_in(key_down: bool):
	var new_zoom_factor := zoom_factor * zoom_key_down_slowdown if key_down else zoom_factor
	_set_zoom_level(_zoom_level + new_zoom_factor)

func _on_cam_zoom_out(key_down: bool):
	var new_zoom_factor := zoom_factor * zoom_key_down_slowdown if key_down else zoom_factor
	_set_zoom_level(_zoom_level - new_zoom_factor)
