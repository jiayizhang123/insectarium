class_name npc1 extends CharacterBody3D

const SPEED = 0
enum ANIMATION {IDLE, INTERACT}
var current_animation := ANIMATION.IDLE
var target_player
var target_player_position
var orientation : Transform3D
var state

var next_nav_position : Vector3
var playerenter =false
var playera
var playerbody
@export var hitpoint = Config.npc_hitpoint
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
		
	$AnimationPlayer.animation_finished.connect(_animation_finished)

func _process(_elta: float) -> void:
	if target_player != null:
		target_player_position = target_player.transform.origin

func set_target_player(player):
	target_player = player
	if target_player != null:
		#target_player_position = target_player.transform.origin
		nav_agent.set_target_position(player.transform.origin)

func _physics_process(_delta):
	
	
	if target_player != null:
		#look_at(target_player.global_transform.origin)
		next_nav_position = nav_agent.get_next_path_position()
		var player_direction = global_position.direction_to(next_nav_position).normalized() * SPEED
		nav_agent.set_velocity(player_direction)
		set_up_direction(Vector3.UP)
		#rotate to the player(speed = 0)
		$Rig.look_at(target_player.global_transform.origin, Vector3(0,1,0))
	else:
		nav_agent.set_velocity(Vector3.ZERO)
	

func character_velocity_computed(calculated_velocity : Vector3) -> void:
	if hitpoint <= 0:
		#change_state(ANIMATION.DIE)
		return
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		# move and slide with the new calculated velocity
		set_velocity(calculated_velocity)
		move_and_slide()

func change_state(newState):
	state = newState
	match state: 
		ANIMATION.IDLE:
			$AnimationPlayer.play("Idle")
		ANIMATION.INTERACT:
			$AnimationPlayer.play("Interact")
		

func _animation_finished(_name):
	if hitpoint <= 0:
		queue_free()
#detect the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		#print("body entered")
		set_target_player(body)
		body.info(str(name))
		change_state(ANIMATION.INTERACT)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		#print( "body exited")
		set_target_player(null)
		#body.info(false)
		#get_parent().get_node("CanvasLayer/info").visible = false
		
