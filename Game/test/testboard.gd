extends Node2D

enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}
enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}

const NONE = "res://test/scenes/orb.tscn"
const YELLOW = "res://test/scenes/yelloworb.tscn"
const BLUE = "res://test/scenes/blueorb.tscn"
const ORANGE = "res://test/scenes/orangeorb.tscn"
const PURPLE = "res://test/scenes/purpleorb.tscn"
const BLACK = "res://test/scenes/blackorb.tscn"
const GREEN = "res://test/scenes/greenorb.tscn"
const WHITE = "res://test/scenes/whiteorb.tscn"
const RED = "res://test/scenes/redorb.tscn"

var numthatfit = 13 #((get_viewport_rect().size.x)/2) / startorb.width

var fallcheckarray = []
var orbsonboard = [] 
var orbsonboardp1 = [] #if either is empty, the game is over
var orbsonoboardp2 = [] 
var s = false
var t  = 0.0

var leftoverorbs = []
var crossreforbs = []
var orb; #the newest orb

onready var p1launcher = get_node("p1launcher")
var p2launcher = null

var player1health = 5
var player2health = 5
var lastusedcolorp1
var lastusedcolorp2
var abilitycountp1 = 0 #counts the number of times a color is chained
var abilitycountp2 = 0

var p1isdark = false
var p1darktime = 1.00
var p1darktimer = 0.00
var p2isdark = false
var p2darktime = 1.00 #time that the darkness ability lasts
var p2darktimer = 0.00 #timer that counts how long the darkness has gone for

#test


func _ready():
	
	GenerateP2Launcher()
	GenerateBoardP1()
	GenerateBoardP2()
	
	set_fixed_process(true)

func _fixed_process(delta):
	#for whatever reason the physics of the orbs does not work as soon as theyre ready
	#so we will wait for one second for them to find their neighbors
	if(t > .5 and s == false):
		for i in orbsonboard:
			i.GetNeighboringPositions()
			i.GetNeighbors()
		s = true
	t += delta
	if(Input.is_action_pressed("ui_select")):
		for orb in orbsonboard:
			orb.CountNeighbors()
	
	if(p2isdark):
		P1BlackAblility(delta)
	if(p1isdark):
		P2BlackAbility(delta)

func GenerateBoardP1():
	#generate board based off of the width of the screen and the width of an orb
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 35 + 10
	var yoffset = 40
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	var orbwidth = startorb.width
	
	startorb.queue_free() #this is kind of cheap but whatever
	
	for i in range (1,5) : #lets say we want four rows
		if(i%2 == 1):
			GenerateOddRow(xoffset, yoffset, orbwidth,1) #always start with an odd row
		elif(i%2 == 0):
			GenerateEvenRow(xoffset, yoffset, orbwidth,1)
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;

func GenerateBoardP2():
	#generate board based off of the width of the screen and the width of an orb
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 960 + 70 + 5
	var yoffset = 40
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	var orbwidth = startorb.width
	
	startorb.queue_free() #this is kind of cheap but whatever
	
	for i in range (1,5) : #lets say we want four rows
		if(i%2 == 1):
			GenerateOddRow(xoffset, yoffset, orbwidth,2) #always start with an odd row
		elif(i%2 == 0):
			GenerateEvenRow(xoffset, yoffset, orbwidth,2)
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;


func CheckFall(): #will most likely take one or more kinematic bodies that are the neighboring orbs of the ones that were just matched and killed
	
	for i in leftoverorbs:
		print(i.get_name())
		i.set_opacity(1)
		if i != null:
			print("start")
			var s = i.LookForTop(crossreforbs)
			print("end")
			if s == false:
				for badorb in crossreforbs:
					var x = orbsonboard.find(badorb)
					if(x != -1):
						orbsonboard.remove(x)
					badorb.get_node("AnimationPlayer").play("shrink")
			crossreforbs.clear()
#	for i in orbsonboard:
#		if(i.falling):
#			i.get_node("AnimationPlayer").play("shrink")
	

func GenerateOddRow(xoffset, yoffset, width, player):
	for i in range(numthatfit):
		var orb
		randomize()
		var result = randi() % 8
		if(result == 0):
			orb = preload(YELLOW).instance()
		elif(result == 1):
			orb = preload(BLUE).instance()
		elif(result == 2):
			orb = preload(RED).instance()
		elif(result == 3):
			orb = preload(ORANGE).instance()
		elif(result == 4):
			orb = preload(PURPLE).instance()
		elif(result == 5):
			orb = preload(GREEN).instance()
		elif(result == 6):
			orb = preload(BLACK).instance()
		elif(result == 7):
			orb = preload(WHITE).instance()
		
		add_child(orb)
		orb.set_pos(Vector2(xoffset + width*i, yoffset))
		if(player == 1):
			orb.player = orb.PLAYER.PLAYER1
		elif(player == 2):
			orb.player = orb.PLAYER.PLAYER2
		orbsonboard.push_front(orb)

func GenerateEvenRow(xoffset, yoffset, width, player):
	xoffset += 35
	for i in range(numthatfit - 1):
		var orb
		randomize()
		var result = randi() % 8
		if(result == 0):
			orb = preload(YELLOW).instance()
		elif(result == 1):
			orb = preload(BLUE).instance()
		elif(result == 2):
			orb = preload(RED).instance()
		elif(result == 3):
			orb = preload(ORANGE).instance()
		elif(result == 4):
			orb = preload(PURPLE).instance()
		elif(result == 5):
			orb = preload(GREEN).instance()
		elif(result == 6):
			orb = preload(BLACK).instance()
		elif(result == 7):
			orb = preload(WHITE).instance()
		
		add_child(orb)
		orb.set_pos(Vector2(xoffset + width*i, yoffset))
		if(player == 1):
			orb.player = orb.PLAYER.PLAYER1
		elif(player == 2):
			orb.player = orb.PLAYER.PLAYER2
		orbsonboard.push_front(orb)

func GenerateP2Launcher():
	p2launcher = preload("res://test/scenes/launcher.tscn").instance()
	add_child(p2launcher)
	p2launcher.set_name("p2launcher")
	p2launcher.player = p2launcher.PLAYER.PLAYER2
	p2launcher.set_pos(Vector2(1455,1040))

func GenerateP1Launcher():
	var launcher = preload("res://test/scenes/launcher.tscn").instance()
	add_child(launcher)
	launcher.player = launcher.PLAYER.PLAYER1
	launcher.set_pos(Vector2(465,1040))

func HandleAbility(colour,player):
#	if player = player1
	#	switch(color):
	#		if color == lastusedcolorp1
	#			rack up multiplier effect
	#		else
	#			do regular effect
	print(str(colour))
	print("activating ablity")
	
	if(player == PLAYER.PLAYER1):
		if(colour == COLOUR.RED):
			player2health -= 1
			print("Player 2 health: " + str(player2health))
		if(colour == COLOUR.GREEN):
			player1health += 1
			print("Player 1 health: " + str(player1health))
		if(colour == COLOUR.BLACK):
			get_node("p2darkness").set_hidden(false)
			p2isdark = true
		if(colour == COLOUR.WHITE):
			p2launcher.Freeze()
		if(colour == COLOUR.YELLOW):
			pass
			#set flag on laucher to activate yellow ability
	elif(player == PLAYER.PLAYER2 or player == PLAYER.AI):
		if(colour == COLOUR.RED):
			player1health -= 1
			print("Player 1 health " + str(player1health))
		if(colour == COLOUR.BLACK):
			get_node("p1darkness").set_hidden(false)
			p1isdark = true
		if(colour == COLOUR.WHITE):
			p1launcher.Freeze()

func P1BlackAblility(delta):
	p2darktimer += delta
	if(p2darktimer >= p2darktime):
		get_node("p2darkness").set_hidden(true)
		p2isdark = false
		p2darktimer = 0.00

func P2BlackAbility(delta):
	p1darktimer += delta
	if(p1darktimer >= p1darktime):
		get_node("p1darkness").set_hidden(true)
		p1isdark = false
		p1darktimer = 0.0

func P1GreyAbility():
	pass
	#check first if a spot isn't already accupied by an orb
	#also check if the area right above the potential spawning
	#point does have an orb to connect to so a grey orb doesn't
	#just go through the warp gate and onto you own board

func P2GreyAbility():
	pass