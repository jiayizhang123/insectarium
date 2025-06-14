extends Node

signal playerover(id)
@onready var nav3D : NavigationRegion3D = $NavigationRegion3D

@onready var player = preload("res://player.tscn")
const spiderScene = preload("res://spider.tscn")
const npcScene1 = preload("res://npc1.tscn")
const npcScene2 = preload("res://npc2.tscn")
const insectScene1 = preload("res://beetle.tscn")
const insectScene2 = preload("res://chameleon.tscn")
const insectScene3 = preload("res://treefrog.tscn")
const plantScene1 = preload("res://pumpkin.tscn")
const plantScene2 = preload("res://strawberry.tscn")
const plantScene3 = preload("res://lemon.tscn")

var gameoverf= false
var colori = [Color.RED, Color.BLUE, Color.GREEN, Color.PURPLE, Color.DIM_GRAY]

#square for putting flowers and grasses randomly
@onready var grass = preload("res://asset/plant.tscn")
@onready var daisy = preload("res://asset/daisy.tscn")
@onready var rose = preload("res://asset/rose.tscn")
@onready var bellflower = preload("res://asset/bellflower.tscn")
var _MIN_X = -190
var _MAX_X =  150
var _MIN_Z = -100
var _MAX_Z =  100
var _positions  = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.mesh_lod_threshold = 4.0
	var index = 1
	var indexa = 1
	var indexb = 201 #can not use 1 as body.name ,because server's name = 1
	var indexc = 301
	var indexd = 401
	#print(Config.Players.size())
	$puzzle/reward.visible = false
	$puzzle/reward2.visible = false
	plant() #put the flowers
	for i in Config.Players: #instantiate all the players
		var currentPlayer = player.instantiate()
		#var currentSnake = snakeScene.instantiate()
		currentPlayer.name = str(Config.Players[i].id)
		var newmaterial = StandardMaterial3D.new()
		newmaterial.albedo_color = colori[index-1]
		currentPlayer.get_node("Rig/Skeleton3D/Rogue_Body").set_surface_override_material(0, newmaterial)
		currentPlayer.get_node("Rig/Skeleton3D/Rogue_Cape/Rogue_Cape").set_surface_override_material(0, newmaterial)
		for spawn in get_tree().get_nodes_in_group("spawnposition"):
			if spawn.name == str(index):
				currentPlayer.global_transform = spawn.global_transform
		
		add_child(currentPlayer)
		currentPlayer.playerover.connect(game_overc)
		index += 1
	#instantiate all the spiders	
	for spawn in get_tree().get_nodes_in_group("spiderposition"):
		var currentSpider = spiderScene.instantiate()
		currentSpider.name = str(multiplayer.get_unique_id())
		if spawn.name == str(indexa):
			#print(spawn.name)
			currentSpider.global_transform = spawn.global_transform
			add_child(currentSpider)
		indexa += 1
	#instantiate all the npcs
	for spawn in get_tree().get_nodes_in_group("npcposition"):
		var currentNpc 
		if indexb == 201:
			currentNpc = npcScene1.instantiate()
		else:
			currentNpc = npcScene2.instantiate()
		currentNpc.name = str(indexb)
		if spawn.name == str(indexb):
			currentNpc.global_transform = spawn.global_transform
			add_child(currentNpc)
		indexb += 1
	#instantiate all the insects
	for spawn in get_tree().get_nodes_in_group("insectposition"):
		var currentInsect 
		if indexc == 301 or indexc == 302 or indexc == 303 :
			currentInsect = insectScene1.instantiate()
		elif indexc == 304 :
			currentInsect = insectScene2.instantiate()
		elif indexc == 305 or indexc == 306:
			currentInsect = insectScene3.instantiate()
		currentInsect.name = str(indexc)
		if spawn.name == str(indexc):
			currentInsect.global_transform = spawn.global_transform
			add_child(currentInsect)
		indexc += 1
	#instantiate all the plants
	for spawn in get_tree().get_nodes_in_group("plantposition"):
		var currentPlant 
		if indexd == 401 :
			currentPlant = plantScene1.instantiate()
		elif indexd == 402 :
			currentPlant = plantScene2.instantiate()
		elif indexd == 403:
			currentPlant = plantScene3.instantiate()
		currentPlant.name = str(indexd)
		if spawn.name == str(indexd):
			currentPlant.global_transform = spawn.global_transform
			add_child(currentPlant)
		indexd += 1
	Input.vibrate_handheld() #viberate
	#spawn_snakes.call_deferred(snake_Spawn_count)
	pass # Replace with function body.

func _process(_delta : float) -> void:
	#print(Config.Players.size())
	pass
#if player is dead
func game_overc(id):
	playerover.emit(id)

func plant():
	var indexi=0
	var g 
	for n in range(0, Config.grassposition.size()):
		indexi += 1
		if indexi == 1:
			g = grass.instantiate()
		elif indexi == 2:
			g = daisy.instantiate()
		elif indexi == 3:
			g = rose.instantiate()
		else:
			g = bellflower.instantiate()
			indexi = 0
		$grass.add_child(g)
		g.position.x = Config.grassposition[n][0]
		g.position.y = Config.grassposition[n][1]
		g.position.z = Config.grassposition[n][2]
	
#leave the code, was used to generate flowers, grasses randomly
func randomPlant():
	for x in range(_MIN_X , _MAX_X ,2):
		for z in range(_MIN_Z , _MAX_Z ,2):
			_positions.append(Vector3i(x, 0, z))
	randomize()
	_positions.shuffle()
	for n in range(0, 150):
		#print('['+ str(_positions[n].x)+',0,'+str(_positions[n].z)+'],')
		var g1 = grass.instantiate()
		var g2 = daisy.instantiate()
		var g3 = rose.instantiate()
		var g4 = bellflower.instantiate()
		var g = randi_range(1,8)
		if g < 2:
			$grass.add_child(g1)
			g1.position = _positions[n]
		elif g < 4:
			$grass.add_child(g2)
			g2.position = _positions[n]
		elif g < 6:
			$grass.add_child(g3)
			g3.position = _positions[n]
		else:
			$grass.add_child(g4)
			g4.position = _positions[n]
