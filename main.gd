extends Control

#var voices = DisplayServer.tts_get_voices_for_language("en") #tts engine
#var voice_id = voices[0] #female voice
var audio_player #for backgraound music
@export var port = 8910
var peer
var audio_player1
var audio_player2

func _ready() -> void:
	#set up the environment for multiplayer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(disconnected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	#background audio , win and lost audio effect
	audio_player = AudioStreamPlayer.new() 
	self.add_child(audio_player)
	audio_player.stream = load('res://asset/FarmersMarket.mp3') #background music
	audio_player.stream.loop = true
	audio_player.play()
	audio_player1 = AudioStreamPlayer.new() 
	add_child(audio_player1)
	audio_player1.stream = load('res://asset/mixkit-wrong-answer-fail-notification-946.wav') 
	audio_player2 = AudioStreamPlayer.new() 
	add_child(audio_player2)
	audio_player2.stream = load('res://asset/mixkit-video-game-win-2016.wav') 
	$serverbrowser.joinGame.connect(JoinByIP) #set up signal for joining server
	$Start.disabled = true #server is off by default
	$help.hide() #hide the help menu
	
	
func _process(_delta) -> void:
	
	pass


func peer_connected(id):
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	if Config.players_info.has(id):
		Config.players_info[id].status = -1
	Config.Players.erase(id)
	var players = get_tree().get_nodes_in_group("player")
	for i in players:
		if i.name == "1": #server:
			i.update_score.rpc_id(0, 1,Config.players_info[1].score,Config.players_info[1].taskscore)
		if i.name == str(id):
			i.queue_free()

# called only from clients
func connected_to_server():
	print("connected To Server!")
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
# when disconnecting happens
func disconnected_to_server():
	print("disconnected To Server!")
	var players = get_tree().get_nodes_in_group("player")
	if players.size()>0: #in case not enter into the game
		for i in players:
			#inform server is down
			i.queue_free()
		var scenes = get_tree().get_nodes_in_group("mainscene")
		for k in scenes:
			k.get_node("CanvasLayer/info").toggle("game", "3", 3)
			break
			 #get_node("CanvasLayer/info").toggle("game", "1")
		await get_tree().create_timer(6).timeout
		restart()

# called only from clients
func connection_failed():
	print("Couldn't Connect")
#send player information
@rpc("any_peer")
func SendPlayerInformation(playername, id):
	#if no players has id, add it into array
	if !Config.Players.has(id) and Config.Players.size() < Config.max_players:
		Config.Players[id] ={
			"name" : playername, "id" : id
		}
		
	if multiplayer.is_server():
		#if this is erver, call sendplayerinformation when new one is added
		for i in Config.Players:
			SendPlayerInformation.rpc(Config.Players[i].name, i)

#start game at client and server
@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://main_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	scene.playerover.connect(game_over)
	$serverbrowser.cleanUp()
	self.hide()

#start the server
func serverstart()->bool:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("cannot host: " + str(error))
		return false
	Config.server_status = 1
	#use compress method
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	#$serverbrowser.setUp()
	$serverbrowser.setUpBroadCast("Insectarium Server")
	print("Waiting For Players!")
	return true

func game_win():
	audio_player2.play()
		
	var scenes = get_tree().get_nodes_in_group("mainscene")
	for k in scenes:
		k.get_node("CanvasLayer/info").toggle("game", "2", 3)
		break
	 #get_node("CanvasLayer/info").toggle("game", "1")
	await get_tree().create_timer(10).timeout
	restart.rpc()

func game_over(i):
	#check if all of players are dead
	var game_overf = 1
	for j in Config.players_info:
		if Config.players_info[j].status == 1:
			game_overf = 0
			break
	#game over if all of players are dead
	if game_overf == 1 :
		audio_player1.play()
		
		var scenes = get_tree().get_nodes_in_group("mainscene")
		for k in scenes:
			k.get_node("CanvasLayer/info").toggle("game", "1", 3)
			break
		 #get_node("CanvasLayer/info").toggle("game", "1")
		await get_tree().create_timer(6).timeout
		restart.rpc()

#restart the game when game win or lose
@rpc("any_peer","call_local")
func restart():
	Config.players_info.clear()
	
	var scenes = get_tree().get_nodes_in_group("mainscene")
	for k in scenes:
		#inform server is down
		k.queue_free()
	self.show()
	await get_tree().create_timer(1).timeout
	$Panel/CheckButton.button_pressed = false

func _on_start_pressed(): #pressed to start the game
	StartGame.rpc()
	#$serverbrowser.cleanUp()
	

func _on_help_pressed(): #read out the help message if tts is enabled
	var text1 = "Please help curator of insectarium to complete some tasks, beware of spiders in the forest, \
	click to move, double click to attack, have fun"
	#DisplayServer.tts_speak(text1, voice_id, 100) #read help message
	$help.show()
	

func _on_quit_pressed(): 
	get_tree().quit() #quit game
	
#when a client join by server ip
func JoinByIP(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
#server toggle switch button
func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on: #turn on server
		#$Panel.visible = false
		if serverstart():
			$Panel/CheckButton.text = "ON"
			$Start.disabled = false
	else: #turn off server
		#$Panel.visible = true
		$Start.disabled = true
		$Panel/CheckButton.text = "OFF"
		if peer:
			peer.close()
			$serverbrowser.cleanUp()
		Config.server_status = 0
		multiplayer.multiplayer_peer.close()
		
		#for i in Config.Players:
			#multiplayer.multiplayer_peer.disconnect_peer(Config.Players[i].id)
		Config.Players.clear()
		
	pass # Replace with function body.
