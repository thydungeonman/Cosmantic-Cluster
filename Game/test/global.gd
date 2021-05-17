extends Node

const ARNIE = "res://test/scenes/characters/arnie.tscn"
const ENA = "res://test/scenes/characters/ena.tscn"

var pickedcharp1 = 0
var pickedcharp2 = 0


func _ready():
	set_fixed_process(true)
	

func _fixed_process(delta):
	if(Input.is_action_pressed("ui_fullscreen")):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
