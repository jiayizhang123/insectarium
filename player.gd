class_name Player extends CharacterBody3D
@onready var nav_agent : NavigationAgent3D = get_node("NavigationAgent3D")
#use to create the slashing effect of a knife
@onready var flash = $Rig/Skeleton3D/Knife/Knife/GPUParticles3D

#set navigationagent of the player
@export var nav_agent_radius : float = 15.0
@export var nav_optimize_path : bool = true
@export var nav_avoidance_enabled : bool = true
@export var player_speed_multiplier : float = 10.0
var next_nav_position : Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_enabled = true
#signal of gaming over
signal playerover(id)
#animation enum
enum{IDLE, MOVE, DIE, ATTACK, INTERACT}
var state = IDLE
#used for synchoronize
var syncPos = Vector3(0,0,0)
var syncPos1 = Vector3(0,0,0)
var syncflip :int = 0
var syncState
@export var health1 = 10
var deathf = false
var syncdeathf = deathf
var synchealth = health1
var syncattack = false
# The normal path to the destination
var player_nav_path : Array = []
#encounter with enemy
var enemy1body = []
var enemy1enter = false
#control the attack speed and animation
var attack = false
var attackt = true
#player id and information
var id_p
var players_info = {}
#audio
var audio_player
var audio_player1
var audio_player2
var audio_player3
var dialogf = false
var colori = [Color.RED, Color.BLUE, Color.GREEN, Color.PURPLE, Color.DIM_GRAY]
#set the flag to show the first message when game starts
var firstmessage = 1

func _ready() -> void:
	audio_player = AudioStreamPlayer.new() 
	add_child(audio_player)
	audio_player.stream = load('res://asset/mixkit-winning-chimes-2015.wav') 
	audio_player1 = AudioStreamPlayer.new() 
	add_child(audio_player1)
	audio_player1.stream = load('res://asset/sword-sound-2-36274.wav') 
	audio_player2 = AudioStreamPlayer.new() 
	add_child(audio_player2)
	audio_player2.stream = load('res://asset/mixkit-wrong-electricity-buzz-955.wav') 
	audio_player3 = AudioStreamPlayer.new() 
	add_child(audio_player3)
	audio_player3.stream = load('res://asset/foot-step.mp3') 
	audio_player3.stream.loop = true
	velocity = Vector3.ZERO
	$HealthBar3D.hide()
	# Connect nav agent signal callback functions.
	nav_agent.connect("path_changed",Callable(self,"character_path_changed"))
	nav_agent.connect("target_reached",Callable(self,"character_target_reached"))
	nav_agent.connect("navigation_finished",Callable(self,"character_navigation_finished"))
	nav_agent.connect("velocity_computed",Callable(self,"character_velocity_computed"))
	# config nav agent attributes
	nav_agent.max_speed = player_speed_multiplier
	nav_agent.radius = nav_agent_radius
	#optimize the map
	NavigationServer3D.map_set_merge_rasterizer_cell_scale(nav_agent.get_navigation_map(),0.01)
		
	$AnimationPlayer.animation_finished.connect(_animation_finished)
		
	#nav_agent.avoidance_enabled = true
	#set authority for discerning id
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	#reset player's information in the game
	for i in Config.Players:
		if !Config.players_info.has(i):
			Config.players_info[i] ={
				"name" : Config.Players[i].name, "id" : Config.Players[i].id, "score": 0,"status":1,
				"beetle":0,"chameleon":0,"treefrog":0,"pumpkin":0,"strawberry":0,"lemon":0,"taskscore":0
				}
	update_score.rpc_id(0, 0, 0, 0) #refresh score
	if firstmessage == 1:
		firstmessage = 0
		info("firstm") #show the first message
	
#show the message
func info(st):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		get_parent().get_node("CanvasLayer/info").visible = true
		#dialogf = true
		#print(st)
		id_p = int(str(name))
		if Config.players_info.has(id_p):
			if Config.players_info[id_p].taskscore == 6:
				get_parent().get_node("CanvasLayer/info").toggle("thank", st , 5)
			elif st == "firstm":
				get_parent().get_node("CanvasLayer/info").toggle("firstm", "" , 3)
			else:
				get_parent().get_node("CanvasLayer/info").toggle("dialog", st , 3)
#update score
@rpc("any_peer","call_local")
func update_score(id, score, taskscore):
	if Config.players_info.has(id):
		Config.players_info[id].score = score
		Config.players_info[id].taskscore = taskscore
	
	var index = 1
	for i in Config.players_info:
		var l = "CanvasLayer/Panel/playerlabel" + str(index)
		var star = "CanvasLayer/Panel/star" + str(index)
		var s = Config.players_info[i].name + ":" + str(Config.players_info[i].score)
		if Config.players_info[i].taskscore == 6: 
			get_parent().get_node(star).play("active")
			var game_win = 1
			for j in Config.players_info:
				if Config.players_info[j].taskscore < 6:
					game_win = 0
					break
			if game_win == 1: #if all of players get full taek score
				get_tree().get_root().get_node("main").game_win()
		if Config.players_info[i].status == 0: #if player is dead
			#var red = Color(1.0,0.0,0.0,1.0)
			get_parent().get_node(l).set("theme_override_colors/font_color",Color.DARK_RED)
			playerover.emit(i)
		elif Config.players_info[i].status == -1: #if player is disconnected
			var grey = Color(0.6, 0.6, 0.6, 1)
			get_parent().get_node(l).set("theme_override_colors/font_color",grey)
		var new_s = StyleBoxFlat.new()
		new_s.bg_color = colori[index-1] #set background for each active player
		get_parent().get_node(l).add_theme_stylebox_override("normal", new_s)
		get_parent().get_node(l).text = s
		index += 1


func _physics_process(delta : float) -> void:
	if $Timer.is_stopped():
		$HealthBar3D.hide()
	#check if local player
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		get_parent().get_node("CanvasLayer/SubViewportContainer/SubViewport/Camera3D").position = Vector3(position.x, 30, position.z)
		
		#$ProgressBar.value =  synchealth
		$HealthBar3D.update_health(synchealth, Config.player_health)
		$Node3D/Camera3D.current = true
		syncPos = global_position
		syncPos1 = $Marker3D.global_rotation
		syncState = state
		synchealth = health1
		if health1 <= 0:
			if !deathf:
				state = DIE
				deathf = true
				change_state(state)
			return
		
		var collidef = 1
		if get_slide_collision_count() > 0:
			var collidebody = get_slide_collision(0)
			collectitem(collidebody)
			if collidebody.get_collider(): #if collide with spider, slow down the moving speed
				if collidebody.get_collider().is_in_group("spider"):
					collidef = 0.05
			
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		#var d =  (get_angle_to(get_global_mouse_position( ))/3.14)*180
		#$Marker2D.rotation = get_angle_to( get_global_mouse_position( ))
		#click and move
		if Input.is_action_just_pressed("ui_mouseleftclick") and !deathf and attackt and !attack:
			#attackt = false
			if Config.dialogf == true: #if dialog completes, hide the information window
				Config.dialogf = false
				get_parent().get_node("CanvasLayer/info").visible = false
				return
			var target_plane_mouse = Plane(Vector3(0,1,0), position.y)
			var ray_length = 7000
			var mouse_position = get_viewport().get_mouse_position()
			var from = $Node3D/Camera3D.project_ray_origin(mouse_position)
			var to = from + $Node3D/Camera3D.project_ray_normal(mouse_position) * ray_length
			var cursor_position_on_plane = target_plane_mouse.intersects_ray(from, to)
			$Rig.look_at(cursor_position_on_plane, Vector3(0,1,0))
			#print($Rig.rotation.y)
			#$Marker3D.rotate_y($Rig.rotation.y) 
			$Marker3D.rotation.y =$Rig.rotation.y 
			get_parent().get_node("CanvasLayer/SubViewportContainer/SubViewport/playerarrow").rotation =4.71-$Rig.rotation.y
			#$Rogue_Hooded.rotate_object_local(Vector3(0,1,0), 3.14)
			nav_agent.set_target_position(cursor_position_on_plane)
		# get the next nav position from the player's navigation agent
		await get_tree().physics_frame
		next_nav_position = nav_agent.get_next_path_position()
		
		#attack
		if attack and !deathf:
			#print("att")
			if $hittimer.is_stopped() :
				$hittimer.start()
				attack = false
				audio_player1.play()
				flash.restart()
				attackt = false
				if enemy1enter :# and attackt:
					for enemy in enemy1body:
						if is_instance_valid(enemy):
							$Rig.look_at(enemy.global_transform.origin, Vector3(0,1,0))
							if enemy.hitpoint == 1:
								add_score("spider")
							enemy.hit.rpc(1)
							enemy.timer1.rpc()
							
						else:
							enemy1body.erase(enemy)
					#attackt = false
				
				state = ATTACK
				change_state(state)
		var desired_velocity = global_position.direction_to(next_nav_position).normalized() * player_speed_multiplier * collidef
		
		#trigger a callback from velocity_computed signal
		nav_agent.set_velocity(desired_velocity)
	else:
		#global_position = global_position.lerp(syncPos, 20*delta) #.5
		#global_transform = lerp(global_transform, syncPos, 20*delta) #.5
		global_transform.origin = lerp(global_transform.origin, syncPos, delta *20)
		#global_position = syncPos
		$Rig.rotation.y = syncPos1.y
		$Marker3D.rotation.y = syncPos1.y
		
		if !deathf:
			if synchealth <= 0:
				state = DIE
				deathf = true
				change_state(state)
			else:
				change_state(syncState)
		$Node3D/Camera3D.current = false
		#$ProgressBar.value = synchealth
		$HealthBar3D.update_health(synchealth, Config.player_health)
#collect item in game
func collectitem(body):
	if body.get_collider():
		if body.get_collider().is_in_group("insects") or body.get_collider().is_in_group("plant"):
			change_state(INTERACT)
			id_p = int(str(name))
			var score = ''
			var task = ''
			audio_player.play()
			Input.vibrate_handheld() #viberate
			var anim = body.get_collider().name
			if Config.players_info.has(id_p):
				if anim== '301' or anim == '302' or anim == '303':
					Config.players_info[id_p].beetle += 1
					score = "insect"
					if Config.players_info[id_p].beetle == Config.beetle:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("beetle").text = "[color=GREEN]Beetle:"+str(Config.players_info[id_p].beetle)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("beetle").text = "Beetle:"+str(Config.players_info[id_p].beetle)
					body.get_collider().queue_free()
				elif anim == '304':
					score = "insect"
					Config.players_info[id_p].chameleon += 1
					if Config.players_info[id_p].chameleon == Config.chameleon:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("chameleon").text = "[color=GREEN]Chameleon:"+str(Config.players_info[id_p].chameleon)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("chameleon").text = "Chameleon:"+str(Config.players_info[id_p].chameleon)
					body.get_collider().queue_free()
				elif anim == '305' or anim == '306':
					score = "insect"
					Config.players_info[id_p].treefrog += 1
					if Config.players_info[id_p].treefrog == Config.treefrog:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("treefrog").text = "[color=GREEN]Treefrog:"+str(Config.players_info[id_p].treefrog)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("treefrog").text = "Treefrog:"+str(Config.players_info[id_p].treefrog)
					body.get_collider().queue_free()
				elif anim == '401':
					score = "plant"
					Config.players_info[id_p].pumpkin += 1
					if Config.players_info[id_p].pumpkin == Config.pumpkin:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("pumpkin").text = "[color=GREEN]Pumpkin:"+str(Config.players_info[id_p].pumpkin)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("pumpkin").text = "Pumpkin:"+str(Config.players_info[id_p].pumpkin)
					body.get_collider().queue_free()
				elif anim == '402':
					score = "plant"
					Config.players_info[id_p].strawberry += 1
					if Config.players_info[id_p].strawberry == Config.strawberry:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("strawberry").text = "[color=GREEN]Strawberry:"+str(Config.players_info[id_p].strawberry)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("strawberry").text = "Strawberry:"+str(Config.players_info[id_p].strawberry)
					body.get_collider().queue_free()
				elif anim == '403':
					score = "plant"
					Config.players_info[id_p].lemon += 1
					if Config.players_info[id_p].lemon == Config.lemon:
						task = 'task'
						get_parent().get_node("CanvasLayer/itemlist").get_node("lemon").text = "[color=GREEN]Lemon:"+str(Config.players_info[id_p].lemon)
					else:
						get_parent().get_node("CanvasLayer/itemlist").get_node("lemon").text = "Lemon:"+str(Config.players_info[id_p].lemon)
					body.get_collider().queue_free()
				add_score(score)
				if task == 'task':
					add_score('task')
#set target
func set_navigation_position(nav_destination : Vector3) -> void:
	if !attack and !deathf:
		# set the new player target location
		nav_agent.set_target_position(nav_destination)
		
		# calculate a new map path with the navigationserver
		#player_nav_path = NavigationServer3D.map_get_path(nav_agent.get_navigation_map(), global_transform.origin, nav_destination, nav_optimize_path)
#add score of items collected
func add_score(scoreid):
	var sc = 0
	if scoreid == "spider":
		sc = 1
	elif scoreid == "gold":
		sc = 10	
	elif scoreid == "insect":
		sc = 5
	elif scoreid == "plant":
		sc = 2
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		id_p = int(str(name))
		if Config.players_info.has(id_p):
			if scoreid == "task":
				Config.players_info[id_p].taskscore += 1
			else:
				Config.players_info[id_p].score += sc
			#get_parent().get_node("CanvasLayer/Panel/Label2").text = "Score:"+str(Config.players_info[id_p].score)
			update_score.rpc_id(0, id_p,Config.players_info[id_p].score, Config.players_info[id_p].taskscore)
			
# hit by enemy
func hit(id):
	#if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		$Timer.stop()
		if id == str(name):
			health1 -= 1
			#print(health1)
			
#if player moves, then set to move animation
func character_path_changed() -> void:
	if attackt and !attack and !deathf and $AnimationPlayer.current_animation != "Interact":
		change_state(MOVE)
		if !audio_player3.is_playing():
			audio_player3.play()
	
func character_target_reached() -> void:
	pass
#if player stops, then set to idle
func character_navigation_finished() -> void:
	audio_player3.stop()
	if attackt and !attack and !deathf and $AnimationPlayer.current_animation != "Interact":
		change_state(IDLE)
#move and slide when moving
func character_velocity_computed(calculated_velocity : Vector3) -> void:
	# check if nav agent target is reached
	if !nav_agent.is_target_reached() and synchealth > 0 and attackt and !attack  :
		# move and slide with the new calculated velocity
		set_velocity(calculated_velocity)
		move_and_slide()
		#smooth the camers
		#$Node3D.global_position = lerp($Node3D.global_position, global_position, 0.15)
		#if get_slide_collision_count() > 0:
			#var collision = get_slide_collision(0)
			#print(collision.get_collider().name)

#if step on all of tiles of the puzzle
func puzzle():
	#if puzzles == 1:
		#tiles.shuffle()
	if Config.reward == 0: #if puzzle has been resolved, return
		return
	var p = true
	if Config.puzzles == 5:
		for i in range(0,4):
			#print(str(Config.tiles[i]) + " " + str(Config.tiles1[i]))
			if Config.tiles[i] != Config.tiles1[i]:
				p = false
				audio_player2.play()
				break
		if p:
			get_parent().get_node("puzzle/reward").visible = true
			
		Config.puzzles = 1
		Config.tiles1.clear()
#if step on all of tiles of the puzzle2
func puzzlea():
	#if puzzles == 1:
		#tiles.shuffle()
	if Config.reward2 == 0: #if puzzle2 has been resolved, return
		return
	var p = true
	if Config.puzzlesa == 5:
		for i in range(0,4):
			print(str(Config.tilesa[i]) + " " + str(Config.tiles1a[i]))
			if Config.tilesa[i] != Config.tiles1a[i]:
				p = false
				audio_player2.play()
				break
		if p:
			get_parent().get_node("puzzle/reward2").visible = true
		Config.puzzlesa = 1
		Config.tiles1a.clear()
#change the animation of player
func change_state(newState):
	state = newState
	match state: 
		IDLE:
			$AnimationPlayer.play("Idle")
		MOVE:
			$AnimationPlayer.play("Walking_B")
		DIE:
			$AnimationPlayer.play("Death_B")
		ATTACK:
			$AnimationPlayer.play("1H_Melee_Attack_Slice_Horizontal",-1,2.5)
		INTERACT:
			$AnimationPlayer.play("Interact")
	if state != MOVE:
		audio_player3.stop()

#if animation finishes and animation is death, set death status
func _animation_finished(aname):
	if aname == "Death_B":
		$CollisionShape3D.set_deferred("disabled", true)
		var id_p1 = int(str(name))
		if Config.players_info.has(id_p1):
			#print("00")
			Config.players_info[id_p1].status = 0
			update_score.rpc_id(0, id_p1,Config.players_info[id_p1].score,Config.players_info[id_p1].taskscore)
	elif aname == "1H_Melee_Attack_Slice_Horizontal" or aname == "Interact":
		change_state(IDLE)
	
	pass
# encounter the spider
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("spider") :
		enemy1enter = true
		if not body in enemy1body: #if this one is not exsted in targets array, then add it
			enemy1body.append(body)
			#body.timer1()
# leave the spider
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("spider") :
		if body in enemy1body:
			enemy1body.erase(body)
		if enemy1body.size() == 0:
			enemy1enter = false
			

#when player click his/her front, attack
func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	##if double click, then attack
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		attack = true
	
#control the attacking frequency
func _on_hittimer_timeout() -> void:
	attackt = true
#set the period of showing progressbar
func timer1():
	if $Timer.is_stopped():
		$HealthBar3D.show()
		$Timer.one_shot = true
		$Timer.wait_time = Config.progressBarTime
		$Timer.start()
#if double click and encountering enemy, then attack
func _input(event): 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if enemy1body.size() >0 :
			attack = true
