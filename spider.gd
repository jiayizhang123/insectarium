class_name spider extends CharacterBody3D

const SPEED = 6
enum ANIMATION {IDLE, WALK,ATTACK,DIE}
var current_animation := ANIMATION.IDLE
var target_player
var target_player_position
var orientation : Transform3D
var state

var next_nav_position : Vector3
var playerenter =false
var playera
var playerbodya
var playerb
var playerbodyb
@export var hitpoint = Config.spider_hitpoint
@onready var nav_agent : NavigationAgent3D = get_node("NavigationAgent3D")

func _ready() -> void:
	#$snakeSynchronizer.set_multiplayer_authority(str(name).to_int())
	#if not multiplayer.is_server():
		#set_process(false)
	velocity = Vector3.ZERO
	# Connect nav agent signal callback functions.
	nav_agent.connect("path_changed",Callable(self,"character_path_changed"))
	nav_agent.connect("target_reached",Callable(self,"character_target_reached"))
	nav_agent.connect("navigation_finished",Callable(self,"character_navigation_finished"))
	nav_agent.connect("velocity_computed",Callable(self,"character_velocity_computed"))
	orientation.origin = Vector3()
	$HealthBar3D.hide()
	$AnimationPlayer.animation_finished.connect(_animation_finished)
#if player in the area, keep moving forward to the player
func _process(_delta: float) -> void:
	if target_player != null:
		target_player_position = target_player.transform.origin
#set the player as target
func set_target_player(player):
	target_player = player
	if target_player != null:
		#target_player_position = target_player.transform.origin
		nav_agent.set_target_position(player.transform.origin)

func _physics_process(_delta):
	if hitpoint <= 0:
		change_state(ANIMATION.DIE)
		return
	if $Timer.is_stopped():
		$HealthBar3D.hide()
	var collidef = 1
	if get_slide_collision_count() > 0:
		var collidebody = get_slide_collision(0)
		if collidebody.get_collider(): #if collide with player, slow down the moving speed
			if collidebody.get_collider().is_in_group("player"):
				collidef = 0.05
	if hitpoint > 0: #if hitpoint>0, attack player
		if target_player != null or playerbodya != null:
			if target_player != null:
				look_at(target_player.global_transform.origin)
			next_nav_position = nav_agent.get_next_path_position()
			var player_direction = global_position.direction_to(next_nav_position).normalized() * SPEED * collidef
			
			nav_agent.set_velocity(player_direction)
			set_up_direction(Vector3.UP)
			change_state(ANIMATION.ATTACK)
		else:
			nav_agent.set_velocity(Vector3.ZERO)
			change_state(ANIMATION.IDLE)
		attackplayer()

#attack
func attackplayer():
	if $hittimer.is_stopped() and hitpoint > 0:
		#print(playerenter)
		if playerenter:
			$hittimer.start()
			change_state(ANIMATION.ATTACK)
			if playerbodya:
				playerbodya.hit(playera)
				playerbodya.timer1()

#move and slide when moving
func character_velocity_computed(calculated_velocity : Vector3) -> void:
	if hitpoint <= 0:
		#change_state(ANIMATION.DIE)
		return
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		# move and slide with the new calculated velocity
		set_velocity(calculated_velocity)
		move_and_slide()
#change animation
func change_state(newState):
	state = newState
	match state: 
		ANIMATION.IDLE:
			$AnimationPlayer.play("Spider_Armature|IdleSpider")
		ANIMATION.WALK:
			$AnimationPlayer.play("Spider_Armature|WalkSpider")
		ANIMATION.ATTACK:
			$AnimationPlayer.play("Spider_Armature|GetDamageSpider",-1,0.5)
		ANIMATION.DIE:
			$AnimationPlayer.play("Spider_Armature|DeathSpider",-1,0.5)

func _animation_finished(_name):
	if hitpoint <= 0:
		queue_free()
#detect the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	#if get_multiplayer_authority() != multiplayer.get_unique_id():
		#return
	if body is Player:
		#print("body entered")
		set_target_player(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		#print( "body exited")
		set_target_player(null)
#encounter with the player
func _on_attack_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		#for i in Config.Players:
			#print(Config.Players[i].id)
			#if body.name == str(Config.Players[i].id):
				#playera = Config.Players[i].id
				#playerbody = body
				#
				##print(str(Config.Players[i].id)+"  ff")
				#break
		playera = body.name
		playerbodya = body
		playerenter = true


func _on_attack_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		playerbodya = null
		playera = ""
		playerenter = false
#if spider is hit, synchronize the situation
@rpc("any_peer", "call_local")
func hit(hitp):
	$Timer.stop()
	#if not multiplayer.is_server(): return
	#if multiplayer.is_server(): 
		#$snakeSynchronizer.replication_config = REPLICATION_MODE_NEVER 
	if hitpoint > 0:
		hitpoint -= hitp
	#print(hitpoint)
		
#synchronize the progressbar
@rpc("any_peer", "call_local")
func timer1():
	
	if $Timer.is_stopped():
		$HealthBar3D.update_health(hitpoint, Config.spider_hitpoint)
		$HealthBar3D.show()
		$Timer.one_shot = true
		$Timer.wait_time = Config.progressBarTime
		$Timer.start()
