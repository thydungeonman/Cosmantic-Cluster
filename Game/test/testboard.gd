extends Node2D

const YELLOW = "res://test/scenes/yelloworb.tscn"
const NONE = "res://test/scenes/orb.tscn"

var fallcheckarray = []
var orbsonboard = []
var s = false
var t  = 0.0

#test

func _ready():
	GenerateBoard()
	set_fixed_process(true)
	

func _fixed_process(delta):
	#for whatever reason the physics of the orbs does not work as soon as theyre ready
	#so we will wait for one second for them to find their neighbors
	if(t > 1 and s == false):
		for i in orbsonboard:
			i.GetNeighboringPositions()
			i.GetNeighbors()
		s = true
	t += delta

func GenerateBoard():
	#generate board based off of the width of the screen and the width of an orb
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var offset = 60
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	
	var numthatfit = (get_viewport_rect().size.x) / startorb.width
	startorb.queue_free() #this is kind of cheap but whatever
	
	for i in range(numthatfit):
		var orb
		if(randi() % 2 == 0):
			orb = preload(YELLOW).instance()
		else:
			orb = preload(NONE).instance()
		
		add_child(orb)
		orb.set_pos(Vector2(offset + orb.width*i, 40))
		orbsonboard.push_front(orb)

func CheckFall(): #will most likely take one or more kinematic bodies that are the neighboring orbs of the ones that were just matched and killed
	pass
	#do the following for each orb
	#if orb.LookForTop(fallcheckarray) == false
		#foreach orb in fallcheck array:
			#orb.fall()
	#else:
		#fallcheckarray = []
	