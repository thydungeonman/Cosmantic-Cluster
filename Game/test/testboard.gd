extends Node2D

const YELLOW = "res://test/scenes/yelloworb.tscn"
const NONE = "res://test/scenes/orb.tscn"

var numthatfit = 13 #((get_viewport_rect().size.x)/2) / startorb.width

var fallcheckarray = []
var orbsonboard = []
var s = false
var t  = 0.0

var leftoverorbs = []

#test

func _ready():
	GenerateBoardP1()
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

func GenerateBoardP1():
	#generate board based off of the width of the screen and the width of an orb
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 52
	var yoffset = 40
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	var orbwidth = startorb.width
	
	startorb.queue_free() #this is kind of cheap but whatever
	
	for i in range (1,5) : #lets say we want four rows
		if(i%2 == 1):
			GenerateOddRow(xoffset, yoffset, orbwidth) #always start with an odd row
		elif(i%2 == 0):
			GenerateEvenRow(xoffset, yoffset, orbwidth)
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;
		
	
	
	

func CheckFall(): #will most likely take one or more kinematic bodies that are the neighboring orbs of the ones that were just matched and killed
	pass
	#do the following for each orb
	#if orb.LookForTop(fallcheckarray) == false
		#foreach orb in fallcheck array:
			#orb.fall()
	#else:
		#fallcheckarray = []


func GenerateOddRow(xoffset, yoffset, width):
	for i in range(numthatfit):
		var orb
		randomize()
		if(randi() % 2 == 0):
			orb = preload(YELLOW).instance()
		else:
			orb = preload(NONE).instance()
		
		add_child(orb)
		orb.set_pos(Vector2(xoffset + width*i, yoffset))
		orbsonboard.push_front(orb)

func GenerateEvenRow(xoffset, yoffset, width):
	xoffset += 35
	for i in range(numthatfit):
		var orb
		randomize()
		if(randi() % 2 == 0):
			orb = preload(YELLOW).instance()
		else:
			orb = preload(NONE).instance()
		
		add_child(orb)
		orb.set_pos(Vector2(xoffset + width*i, yoffset))
		orbsonboard.push_front(orb)