extends HBoxContainer

signal joinGame(ip)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_button_down():
	joinGame.emit($Ip.text)
	$Button.disabled = true
	get_tree().root.get_node("main/Start").disabled = false
	pass # Replace with function body.
