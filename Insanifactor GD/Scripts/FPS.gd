extends Label

var FPS = 0
func _physics_process(delta):
	FPS = 1 / delta
	text = "fps: %s" %floor(FPS) 
