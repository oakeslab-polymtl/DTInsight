extends Camera2D

class_name CameraControl

var mouvement_enabled : bool = true
var currently_zooming : bool = false

func _ready() -> void:
	CameraSignals.disable_camera_mouvement.connect(_disable_camera_mouvement)
	CameraSignals.enable_camera_mouvement.connect(_enable_camera_mouvement)

func _process(delta : float):
	if (mouvement_enabled):
		var inputMouvementVector : Vector2 = handle_mouvement_input()
		moveCamera(inputMouvementVector, delta)
	var inputZoomVector : Vector2 = handle_zoom_input(false)
	zoom_camera(inputZoomVector)

#Movement functions -----------------------------------------------------------
var current_velocity : Vector2 = Vector2(0, 0)
const ACCELERATION_PER_SECOND : float = CameraConfig.Mouvement.MAX_VELOCITY / CameraConfig.Mouvement.SECONDS_TO_REACH_MAX_VELOCITY
const DECELERATION_PER_SECOND : float = CameraConfig.Mouvement.MAX_VELOCITY / CameraConfig.Mouvement.SECONDS_TO_STOP_FROM_MAX_VELOCITY

func handle_mouvement_input() -> Vector2:
	var input_vector : Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("cam_move_left"):
		input_vector += Vector2(-1, 0)
	if Input.is_action_pressed("cam_move_right"):
		input_vector += Vector2(1, 0)
	if Input.is_action_pressed("cam_move_down"):
		input_vector += Vector2(0, 1)
	if Input.is_action_pressed("cam_move_up"):
		input_vector += Vector2(0, -1)
	return input_vector.normalized()

func moveCamera(input_vector : Vector2, delta : float) -> void:
	var scaled_input : Vector2 = input_vector * ACCELERATION_PER_SECOND * delta
	if (input_vector != Vector2.ZERO): #acceleration
		var max_x_velocity = CameraConfig.Mouvement.MAX_VELOCITY if input_vector.normalized().x == 0 else CameraConfig.Mouvement.MAX_VELOCITY * abs(input_vector.normalized().x)
		var max_y_velocity = CameraConfig.Mouvement.MAX_VELOCITY if input_vector.normalized().y == 0 else CameraConfig.Mouvement.MAX_VELOCITY * abs(input_vector.normalized().y)
		current_velocity.x = clamp(current_velocity.x + scaled_input.x, -max_x_velocity, max_x_velocity)
		current_velocity.y = clamp(current_velocity.y + scaled_input.y, -max_y_velocity, max_y_velocity)
	if(input_vector.x == 0 or opposite_signs(input_vector.x, current_velocity.x)):
		decelerate_x(delta)
	if(input_vector.y == 0 or opposite_signs(input_vector.y, current_velocity.y)):
		decelerate_y(delta)
	translate(current_velocity)

func decelerate_x(delta : float) -> void:
	var pre_velocity = current_velocity.x
	current_velocity.x -= current_velocity.normalized().x * DECELERATION_PER_SECOND * delta
	if (opposite_signs(pre_velocity, current_velocity.x)):
		current_velocity.x =0

func decelerate_y(delta : float) -> void:
	var pre_velocity = current_velocity.y
	current_velocity.y -= current_velocity.normalized().y * DECELERATION_PER_SECOND * delta
	if (opposite_signs(pre_velocity, current_velocity.y)):
		current_velocity.y =0

func opposite_signs(x:float, y:float) -> bool:
	return ((x * y) < 0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT:
		handle_mouse_mouvement(event)
	var inputZoomVector : Vector2 = handle_zoom_input(true)
	zoom_camera(inputZoomVector)

func handle_mouse_mouvement(event : InputEventMouseMotion) -> void:
	translate(-event.relative / zoom)

#Camera functions --------------------------------------------------------------
func handle_zoom_input(using_mouse : bool):
	var input_vector : Vector2 = Vector2(0, 0)
	if not using_mouse:
		if Input.is_action_pressed("cam_zoom_in"):
			input_vector += Vector2(CameraConfig.Zoom.ZOOM_KEY_SPEED, CameraConfig.Zoom.ZOOM_KEY_SPEED)
		if Input.is_action_pressed("cam_zoom_out"):
			input_vector += Vector2(-CameraConfig.Zoom.ZOOM_KEY_SPEED, -CameraConfig.Zoom.ZOOM_KEY_SPEED)
	else:
		if Input.is_action_just_released("cam_scroll_zoom_in"):
			input_vector += Vector2(CameraConfig.Zoom.ZOOM_SCROLL_SPEED, CameraConfig.Zoom.ZOOM_SCROLL_SPEED)
		if Input.is_action_just_released("cam_scroll_zoom_out"):
			input_vector += Vector2(-CameraConfig.Zoom.ZOOM_SCROLL_SPEED, -CameraConfig.Zoom.ZOOM_SCROLL_SPEED)
	return input_vector

func zoom_camera(input_vector: Vector2):
	zoom = clamp(lerp(zoom, zoom + input_vector, 0.01), Vector2(CameraConfig.Zoom.MAX_ZOOM_OUT_SCALE, CameraConfig.Zoom.MAX_ZOOM_OUT_SCALE), Vector2(CameraConfig.Zoom.MAX_ZOOM_IN_SCALE, CameraConfig.Zoom.MAX_ZOOM_IN_SCALE))

#Signal handling ---------------------------------------------------------------
func _disable_camera_mouvement() -> void:
	mouvement_enabled = false

func _enable_camera_mouvement() -> void:
	mouvement_enabled = true

func zoom_to_fit(target_rect: Rect2):
	var viewport_size = get_viewport_rect().size
	var scale_x = viewport_size.x / target_rect.size.x
	var scale_y = viewport_size.y / target_rect.size.y

	# Use the smaller scale to ensure the whole target fits
	var zoom_factor = min(scale_x, scale_y)
	zoom = Vector2(zoom_factor, zoom_factor)

	# Center the camera on the target
	position = target_rect.position + target_rect.size * 0.5
