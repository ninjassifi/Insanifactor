extends TileMap

# Tile stuff
@export var tileSize = 64;

# Size of chunks (in tiles)
var chunkSizeX = 2;
var chunkSizeY = 2;

# Weather or not to generate on the fly or generate all at once
const allAtOnce = true;

# Perlin noise maps
var biome = FastNoiseLite.new();
var altitude = FastNoiseLite.new();

# Get player coords to generate chunks
@onready var player = get_node("/root/Main/Player");

@onready var camera = get_node("/root/Main/Player/Camera");

# Get screen size to make enough of the chunks to fill screen
var screenSize;

func _ready():
	
	biome.seed = randi();
	altitude.seed = randi();

func _process(delta):
	#print(player.position)
	
	screenSize = get_viewport_rect().size;
	
	chunkSizeX = screenSize.x / tileSize;
	chunkSizeY = screenSize.y / tileSize;
	
	generateChunk(player.position);

func generateChunk(position):
	var tilePos = local_to_map(position / scale);
	print(tilePos)
	for x in range(chunkSizeX):
		for y in range(chunkSizeY):
			var alt = altitude.get_noise_2d(tilePos.x + x, tilePos.y + y);
			
			set_cell(0, Vector2i((tilePos.x + x) - chunkSizeX / 2, (tilePos.y + y) - chunkSizeY / 2), 0, Vector2i(0, floor(alt + 1)));
			
func convertFromTilepos(position):
	position.x *= tileSize;
	position.y *= tileSize;
	return position;
