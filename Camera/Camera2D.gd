extends Camera2D

#Mouvement config
const maxVelocity : float = 20
const secondsToReachMaxVelocity : float = 0.2
const secondsToStopFromMaxVelocity : float = 0.05

#Camera config
const maxZoomInScale : float = 2
const maxZoomOutScale : float = 0.3
const zoomPerSecond : float = 1

func _process(delta):
	var inputMouvementVector : Vector2 = handle_mouvement_input()
	moveCamera(inputMouvementVector, delta)
	var inputZoomVector : Vector2 = handle_zoom_input()
	zoomCamera(inputZoomVector, delta)

#Mouvement functions -----------------------------------------------------------
var currentVelocity : Vector2 = Vector2(0, 0)
const accelerationPerSecond : float = maxVelocity / secondsToReachMaxVelocity
const decelerationPerSecond : float = maxVelocity / secondsToStopFromMaxVelocity

func handle_mouvement_input() -> Vector2:
	var inputVector : Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("cam_move_left"):
		inputVector += Vector2(-1, 0)
	if Input.is_action_pressed("cam_move_right"):
		inputVector += Vector2(1, 0)
	if Input.is_action_pressed("cam_move_down"):
		inputVector += Vector2(0, 1)
	if Input.is_action_pressed("cam_move_up"):
		inputVector += Vector2(0, -1)
	return inputVector.normalized()

func moveCamera(inputVector : Vector2, delta):
	var scaledInput : Vector2 = inputVector * accelerationPerSecond * delta
	if (inputVector != Vector2.ZERO): #acceleration
		var maxXVelocity = maxVelocity if inputVector.normalized().x == 0 else maxVelocity * abs(inputVector.normalized().x)
		var maxYVelocity = maxVelocity if inputVector.normalized().y == 0 else maxVelocity * abs(inputVector.normalized().y)
		currentVelocity.x = clamp(currentVelocity.x + scaledInput.x, -maxXVelocity, maxXVelocity)
		currentVelocity.y = clamp(currentVelocity.y + scaledInput.y, -maxYVelocity, maxYVelocity)
	if(inputVector.x == 0 or opposite_signs(inputVector.x, currentVelocity.x)):
		decelerate_x(delta)
	if(inputVector.y == 0 or opposite_signs(inputVector.y, currentVelocity.y)):
		decelerate_y(delta)
	translate(currentVelocity)

func decelerate_x(delta):
	var preVelocity = currentVelocity.x
	currentVelocity.x -= currentVelocity.normalized().x * decelerationPerSecond * delta
	if (opposite_signs(preVelocity, currentVelocity.x)):
		currentVelocity.x =0

func decelerate_y(delta):
	var preVelocity = currentVelocity.y
	currentVelocity.y -= currentVelocity.normalized().y * decelerationPerSecond * delta
	if (opposite_signs(preVelocity, currentVelocity.y)):
		currentVelocity.y =0

func opposite_signs(x:float, y:float) -> bool:
	return ((x * y) < 0)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_LEFT:
		handle_mouse_mouvement(event)

func handle_mouse_mouvement(event : InputEventMouseMotion):
	translate(-event.relative)

#Camera functions --------------------------------------------------------------
func handle_zoom_input() -> Vector2:
	var inputVector : Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("cam_zoom_in"):
		inputVector += Vector2(zoomPerSecond, zoomPerSecond)
	if Input.is_action_pressed("cam_zoom_out"):
		inputVector += Vector2(-zoomPerSecond, -zoomPerSecond)
	return inputVector

func zoomCamera(inputVector : Vector2, delta):
	var scaledInput : Vector2 = inputVector * zoomPerSecond * delta
	zoom = clamp(zoom + scaledInput, Vector2(maxZoomOutScale, maxZoomOutScale), Vector2(maxZoomInScale, maxZoomInScale))
