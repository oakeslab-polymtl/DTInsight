extends Node

#Mouvement config
class Mouvement:
	const maxVelocity : float = 20
	const secondsToReachMaxVelocity : float = 0.2
	const secondsToStopFromMaxVelocity : float = 0.05

#Camera config
class Zoom:
	const maxZoomInScale : float = 2
	const maxZoomOutScale : float = 0.3
	const zoomPerSecond : float = 1
