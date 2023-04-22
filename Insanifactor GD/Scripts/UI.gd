extends Control

var camera;
var screen_size;

func _ready():
	camera = get_node("/root/Main/Player");
	
func _process(delta):
	screen_size = get_viewport_rect().size
	position = camera.position - (screen_size / 2);
