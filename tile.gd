extends StaticBody3D

var audio_player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player = AudioStreamPlayer.new() 
	add_child(audio_player)
	audio_player.stream = load('res://asset/stonegrind-82327.wav') 
	global_transform.origin.y = 2.5
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

#tile is pressed
func _on_area_3d_body_entered(body: Node3D) -> void:
		#$AnimatedSprite2D.frame = 0
	#global_transform.origin.y = 2.2
	audio_player.play()
	#print(body.name)
	if body is Player:
		global_transform.origin.y = 2.2
		if int(str(self.name)) < 5:
			if Config.puzzles == 1:
				Config.playerpuzzles = str(body.name)
			if Config.playerpuzzles == str(body.name):
				Config.tiles1.append(int(str(self.name)))
				Config.puzzles += 1
				body.puzzle()
		else:
			if Config.puzzlesa == 1:
				Config.playerpuzzlesa = str(body.name)
			if Config.playerpuzzlesa == str(body.name):
				Config.tiles1a.append(int(str(self.name)))
				Config.puzzlesa += 1
				body.puzzlea()

#tile is released
func _on_area_3d_body_exited(body: Node3D) -> void:
	global_transform.origin.y = 2.5
