extends StaticBody3D

var audio_player

func _ready() -> void:
	audio_player = AudioStreamPlayer.new() 
	add_child(audio_player)
	audio_player.stream = load('res://asset/Power_up_6.wav') #


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		if body.health1 < 10:
			body.health1 = 10
			audio_player.play()
			body.timer1()
