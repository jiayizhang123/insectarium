extends TextureProgressBar

var bar_red = preload("res://asset/barHorizontal_red_mid 200.png")
var bar_green = preload("res://asset/barHorizontal_green_mid 200.png")
var bar_yellow = preload("res://asset/barHorizontal_yellow_mid 200.png")

func _ready():
	hide()

func update_health1(_value, _max_value):
	value = _value
	if value < _max_value:
		show()
	texture_progress = bar_green
	if value < 0.75 * _max_value:
		texture_progress = bar_yellow
	if value < 0.45 * _max_value:
		texture_progress = bar_red
