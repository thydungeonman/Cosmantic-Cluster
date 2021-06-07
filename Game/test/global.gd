extends Node

const ARNIE = "res://test/scenes/characters/arnie.tscn"
const ENA = "res://test/scenes/characters/ena.tscn"

var pickedcharp1 = 0
var pickedcharp2 = 0

#map variables
var comingbackfromlevel = false #this might technically always be true since when starting the game these values will be loaded from a save file
var selectedroute = 0
var selectedlevel = 0
var goaround = 0
var positionroute = 0 
var positionpath = 0 
var fountainoffset = 0
var mountainoffset = 0
var mansionoffset = 0
var wentmountain = false

func _ready():
	set_fixed_process(true)
	

func _fixed_process(delta):
	if(Input.is_action_pressed("ui_fullscreen")):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
