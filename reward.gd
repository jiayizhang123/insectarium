extends StaticBody3D

var audio_player

func _ready() -> void:
	audio_player = AudioStreamPlayer.new() 
	add_child(audio_player)
	audio_player.stream = load('res://asset/mixkit-winning-chimes-2015.wav') 
	
#when puazle solved, show the trophy
func _on_area_3d_body_entered(body: Node3D) -> void:
	if self.visible and body.has_method("add_score"):
		body.add_score("gold")
		body.change_state(body.INTERACT)
		self.visible = false
		if name == "reward":
			Config.reward = 0
		elif name == "reward2":
			Config.reward2 = 0
		audio_player.play()
		Input.vibrate_handheld()
