extends Control

var tween1 :Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RichTextLabel.text = ""
	#get_parent().propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	clear()

#display the message
func toggle(scene, n, t):
	if scene == "dialog": #dialog with NPC
		for spawn in get_tree().get_nodes_in_group("npcposition"):
			if n == str(spawn.name):
				$RichTextLabel.text = Config.dialog[(int(str(n))-201)*3+Config.dialogi[int(str(n))-201]]
		Config.dialogi[int(str(n))-201] += 1
		if Config.dialogi[int(str(n))-201] > 2:
			Config.dialogi[int(str(n))-201] = 0
	if scene == "game":
		if n == '1': #game lose
			$RichTextLabel.text = Config.game[int(n)-1]
		elif n == '2': # game win and display the highest score
			var winner_score = 0
			var winner_name = ''
			var winner_id = 0
			for j in Config.players_info:
				if Config.players_info[j].score > winner_score:
					winner_score = Config.players_info[j].score
					winner_name = Config.players_info[j].name
					winner_id = Config.players_info[j].id
			var s = "\n Winner: " +winner_name + " Score: " + str(winner_score)
			for j in Config.players_info:
				if Config.players_info[j].score == winner_score and Config.players_info[j].id != winner_id:
					s = s + "\n Winner: " + Config.players_info[j].name + " Score: " + str(winner_score)
			#print(s)
			$RichTextLabel.text = Config.game[int(n)-1] + s
		
	if scene == "thank": #if player complete the task
		$RichTextLabel.text = Config.thank
	if scene == "firstm": #first message when playing game
		$RichTextLabel.text = Config.firstm
	#$RichTextLabel.visible = false
	self.visible = true
	$RichTextLabel.visible = true
	$RichTextLabel.visible_ratio = 0
	tween1 = create_tween() #display characters of message one by one
	#tween1.bind_node(self)
	tween1.tween_property($RichTextLabel,"visible_ratio",1,t)
	tween1.connect("finished",Callable(self,"effect_completed"))
	tween1.play()
		
		#tween.tween_property($RichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#else:
	#	self.visible = false
	#	clear()
#if display of message completes
func effect_completed():
	Config.dialogf = true
	#$Button.visible = true
#hide message window
func clear():
	self.visible = false
	$RichTextLabel.visible = false
	
