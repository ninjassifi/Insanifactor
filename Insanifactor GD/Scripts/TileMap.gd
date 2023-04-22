extends TileMap

# Tile stuff
@export var tileSize = 16;

# Size of chunks (in tiles)
var chunkSizeX = 4;
var chunkSizeY = 4;

var generatedChunks = {};

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
	# Get screen size to figure out how big to create chunks
	screenSize = get_viewport_rect().size;
	
	#generateChunk(player.position);
	generateRadius(0, player.position);

func generateRadius(radius, position):
	var tilePos = local_to_map(position / scale);
	generateChunk(tilePos);

func generateChunk(position):
	
	# We get the pos for the chunk we generate, it is the tile position / chunk size
	var tilePos = Vector2i.ZERO; # = local_to_map(position / scale);
	var chunkPos = convertToChunkpos(position);
	
	
	
	# If it is not generated, run the generation script
	if (generatedChunks.get(chunkPos) == null):
		generatedChunks[chunkPos] = true;
		
		# Debug
		print(chunkPos)
		print(player.position)
		
		# Get the actual tileposition but with steps of chunk position and offset so that the chunks generate when in the chunk area
		tilePos.x = chunkPos.x * chunkSizeX - chunkSizeX;
		tilePos.y = chunkPos.y * chunkSizeY - chunkSizeY;
		
		# Generate from 0 to chunkSize
		for x in range(chunkSizeX):
			for y in range(chunkSizeY):
				var alt = altitude.get_noise_2d(tilePos.x + x, tilePos.y + y);
			
				set_cell(0, Vector2i(tilePos.x + x, tilePos.y + y), 0, Vector2i(0, floor(alt + 1)));
				
				
				#var alt = altitude.get_noise_2d(chunkPos.x + x, chunkPos.y + y);
			
				#set_cell(0, Vector2i(chunkPos.x + x, chunkPos.y + y), 0, Vector2i(0, floor(alt + 1)));

func convertToChunkpos(position):
	var chunkPos = Vector2();
	chunkPos.x = floor(position.x / chunkSizeX);
	chunkPos.y = floor(position.y / chunkSizeY);
	return chunkPos;
	
func convertFromTilepos(position):
	position.x *= tileSize;
	position.y *= tileSize;
	return position;
