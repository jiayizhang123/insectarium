class_name insect extends CharacterBody3D

const SPEED = 0
enum ANIMATION {IDLE}
var current_animation := ANIMATION.IDLE
var target_player
var target_player_position
var orientation : Transform3D
var state


var next_nav_position : Vector3


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
	
	

func _process(_delta: float) -> void:
	if target_player != null:
		target_player_position = target_player.transform.origin
#set the target
func set_target_player(player):
	target_player = player
	if target_player != null:
		#target_player_position = target_player.transform.origin
		nav_agent.set_target_position(player.transform.origin)

func _physics_process(_delta):
	if target_player != null:
		look_at(target_player.global_transform.origin)
		next_nav_position = nav_agent.get_next_path_position()
		var player_direction = global_position.direction_to(next_nav_position).normalized() * SPEED

		nav_agent.set_velocity(player_direction)
		set_up_direction(Vector3.UP)
		#rotate to the player(speed = 0)
		look_at(target_player.global_transform.origin, Vector3(0,1,0))
		rotation.x = 0
		rotation.z = 0
		#rotation.y = lerp_angle( rotation.y, atan2( target_player.global_transform.origin.x, target_player.global_transform.origin.z ), 1 )
	else:
		nav_agent.set_velocity(Vector3.ZERO)
		

#leave the code
func character_velocity_computed(calculated_velocity : Vector3) -> void:
	# check if nav agent target is reached
	if !nav_agent.is_target_reached():
		# move and slide with the new calculated velocity
		set_velocity(calculated_velocity)
		move_and_slide()

#detect the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		#print("body entered")
		set_target_player(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		#print( "body exited")
		set_target_player(null)
