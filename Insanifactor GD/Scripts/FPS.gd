extends Label

var FPS = 0
func _process(delta):
	FPS = 1 / delta
	text = "fps: %s" %floor(FPS) 
