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

onready var music = get_node("backgroundmusic")
onready var sfx = get_node("SamplePlayer2D")

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

var p1flag #flag orbs
var p2flag

var player1health = 5
var player2health = 5
var lastusedcolorp1
var lastusedcolorp2
var abilitycountp1 = 0 #counts the number of times a color is chained
var abilitycountp2 = 0
var p1isnegated = false # these are for when a player has their next ability negated by a purple ability
var p2isnegated = false

var p1isdark = false
var p1darktime = 1.00
var p1darktimer = 0.00
var p2isdark = false
var p2darktime = 1.00 #time that the darkness ability lasts
var p2darktimer = 0.00 #timer that counts how long the darkness has gone for

#test
onready var ray = get_node("RayCast2D")

func _ready():
	music.play(0)
	
	GenerateP2Launcher()
	GeneratePlayer1Flag()
	GeneratePlayer2Flag()
	GenerateBoardP1()
	GenerateBoardP2()

	
	set_fixed_process(true)

func _fixed_process(delta):
	if(Input.is_action_pressed("ui_page_up")):
		p1launcher.Charge()
		p2launcher.Charge()
	
	if(Input.is_action_pressed("click")):
		Click()
	if(Input.is_action_pressed("rclick")):
		RClick()
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
	var xoffset = 35 + 17
	var yoffset = 40 + (70 * 3)
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
		print(str(orbwidth))

func GenerateBoardP2():
	#generate board based off of the width of the screen and the width of an orb
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 960 + 68
	var yoffset = 40 + (70 * 3)
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	startorb.player = PLAYER.PLAYER2
	var orbwidth = startorb.width
	
	startorb.queue_free() #this is kind of cheap but whatever
	
	for i in range (1,5) : #lets say we want four rows
		if(i%2 == 1):
			GenerateOddRow(xoffset, yoffset, orbwidth,2) #always start with an odd row
		elif(i%2 == 0):
			GenerateEvenRow(xoffset, yoffset, orbwidth,2)
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;


func CheckFall(): #will most likely take one or more kinematic bodies that are the neighboring orbs of the ones that were just matched and killed
	print("checking fall" + " " + str(leftoverorbs.size()))
	var orbfell = false
	for i in leftoverorbs:
		print(i.get_name())
		i.set_opacity(1)
		if i != null:
			print("start")
			var s = i.LookForTop(crossreforbs)
			print("end")
			if s == false:
				for badorb in crossreforbs:
					orbfell = true
					var x = orbsonboard.find(badorb)
					if(x != -1):
						orbsonboard.remove(x)
					badorb.get_node("AnimationPlayer").play("shrink")
			crossreforbs.clear()
	if(orbfell):
		sfx.play("punch sound - falling orbs")
		print("sfx played")
	

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
	p2launcher.set_pos(Vector2(1447,1040))

func GenerateP1Launcher():
	var launcher = preload("res://test/scenes/launcher.tscn").instance()
	add_child(launcher)
	launcher.player = launcher.PLAYER.PLAYER1
	launcher.set_pos(Vector2(465,1040))

func HandleAbility(colour,player):

	print(str(colour))
	print("activating ablity")
	
	if(player == PLAYER.PLAYER1 and !p1isnegated):
		if(colour == COLOUR.RED):
			player2health -= 1
			p2launcher.get_node("health").set_text("Health " + str(player2health))
			sfx.play("fireworks-mortar - Red ability used Hp loss")
		if(colour == COLOUR.GREEN):
			player1health += 1
			print("Player 1 health: " + str(player1health))
			p1launcher.get_node("health").set_text("Health " + str(player1health))
			sfx.play("another-magic-wand-spell-tinkle - Green ability used Hp Gain")
		if(colour == COLOUR.BLACK):
			get_node("p2darkness").set_hidden(false)
			p2isdark = true
			sfx.play("dark magic loop - Black ability used")
		if(colour == COLOUR.WHITE):
			p2launcher.Freeze()
			sfx.play("winter wind - White ability used")
		if(colour == COLOUR.YELLOW):
			p1launcher.Charge()
			if(p1isdark):
				p1darktimer = p1darktime
				p1isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		if(colour == COLOUR.BLUE):
			P1BlueAbility()
			sfx.play("billiard-balls-single-hit-dry - Grey orbs spawn")
		if(colour == COLOUR.PURPLE):
			p2isnegated = true
			sfx.play("moved-02-dark - Purple ability used")
		if(colour == COLOUR.ORANGE):
			p1launcher.ActivateLaser()
	elif(player == PLAYER.PLAYER1 and p1isnegated):
		p1isnegated = false
	elif((player == PLAYER.PLAYER2 or player == PLAYER.AI) and !p2isnegated):
		if(colour == COLOUR.RED):
			player1health -= 1
			print("Player 1 health " + str(player1health))
			p1launcher.get_node("health").set_text("Health " + str(player1health))
			sfx.play("fireworks-mortar - Red ability used Hp loss")
		if(colour == COLOUR.GREEN):
			player2health += 1
			print("Player 2 health: " + str(player2health))
			p2launcher.get_node("health").set_text("Health " + str(player2health))
			sfx.play("another-magic-wand-spell-tinkle - Green ability used Hp Gain")
		if(colour == COLOUR.BLACK):
			get_node("p1darkness").set_hidden(false)
			p1isdark = true
			sfx.play("dark magic loop - Black ability used")
		if(colour == COLOUR.WHITE):
			p1launcher.Freeze()
			sfx.play("winter wind - White ability used")
		if(colour == COLOUR.YELLOW):
			p2launcher.Charge()
			if(p2isdark):
				p2darktimer = p2darktime
				p2isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		if(colour == COLOUR.BLUE):
			P2BlueAbility()
			sfx.play("billiard-balls-single-hit-dry - Grey orbs spawn")
		if(colour == COLOUR.PURPLE):
			p1isnegated = true
			sfx.play("moved-02-dark - Purple ability used")
		if(colour == COLOUR.ORANGE):
			p2launcher.ActivateLaser()
	elif(player == PLAYER.PLAYER2 and p2isnegated):
		p2isnegated = false

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

func P1BlueAbility():
	var orb = FindAvailableSpot(PLAYER.PLAYER2)
	if(orb == null):
		return #couldn't find an orb. bail out
	else:
		var grey = preload("res://test/scenes/greyorb.tscn").instance()
		add_child(grey)
		if(orb.bottomleft == null):
			grey.set_pos(orb.bottomleftspot)
		elif(orb.bottomright == null):
			grey.set_pos(orb.bottomrightspot)
		grey.HookUp()
		orbsonboard.push_back(grey)

func P2BlueAbility():
	var orb = FindAvailableSpot(PLAYER.PLAYER1)
	if(orb == null):
		return #couldn't find an orb. bail out
	else:
		var grey = preload("res://test/scenes/greyorb.tscn").instance()
		add_child(grey)
		if(orb.bottomleft == null):
			grey.set_pos(orb.bottomleftspot)
		elif(orb.bottomright == null):
			grey.set_pos(orb.bottomrightspot)
		grey.HookUp()
		orbsonboard.push_back(grey)


func Click():
	#P2BlueAbility()
	var mousepos = get_viewport().get_mouse_pos()
	ray.set_cast_to(mousepos - ray.get_global_pos())
	if(ray.get_collider() != null):
		print(ray.get_collider().get_name())
	var testorb = ray.get_collider()
	if(testorb != null):
		if(testorb.is_in_group("orb")):
			var group = []
			testorb.Search(1,COLOUR.NONE,group)
			print(str(group.size()))
func RClick():
	#P1BlueAbility()
	pass

func FindAvailableSpot(player):
	#finds the first available spot for a gray orb to be spawned for the player that is passed to the function
	#usually is the last orb that player fired
	for orb in orbsonboard:
		if(orb.player == player):
			if(orb.CountNeighbors() < 6 and (orb.bottomleft == null or orb.bottomright == null) and !orb.inlauncher and !orb.ismoving):
				print(str(orb.get_name()))
				return orb
			else:
				return null

func GeneratePlayer1Flag():
	p1flag = preload("res://test/scenes/flagorb.tscn").instance()
	var s = Image()
	
	randomize()
	var result = randi() % 8
	if(result == 0):
		s.load("res://test/sprites/flag orb yellow.png")
		p1flag.colour = COLOUR.YELLOW
	elif(result == 1):
		s.load("res://test/sprites/flag orb blue.png")
		p1flag.colour = COLOUR.BLUE
	elif(result == 2):
		s.load("res://test/sprites/flagorbred.png")
		p1flag.colour = COLOUR.RED
	elif(result == 3):
		s.load("res://test/sprites/flag orb orange.png")
		p1flag.colour = COLOUR.ORANGE
	elif(result == 4):
		s.load("res://test/sprites/flag orb purple.png")
		p1flag.colour = COLOUR.PURPLE
	elif(result == 5):
		s.load("res://test/sprites/flag orb green.png")
		p1flag.colour = COLOUR.GREEN
	elif(result == 6):
		s.load("res://test/sprites/flag orb black.png")
		p1flag.colour = COLOUR.BLACK
	elif(result == 7):
		s.load("res://test/sprites/flag orb white.png")
		p1flag.colour = COLOUR.WHITE
	print("flag1 colour: " + str(p1flag.colour))
	p1flag.get_node("Sprite").get_texture().create_from_image(s)
	randomize()
	var p = randi() % 11
	add_child(p1flag)
	orbsonboard.push_back(p1flag)
	p1flag.set_pos(Vector2(17 + 70 + (70 * p),40 + 70 + 70 + 70 - (70 * Vector2(1.07337749,1.8417709).normalized().y)))

func GeneratePlayer2Flag():
	p2flag = preload("res://test/scenes/flagorb2.tscn").instance()
	var s = Image()
	
	randomize()
	var result = randi() % 8
	if(result == 0):
		s.load("res://test/sprites/flag orb yellow.png")
		p2flag.colour = COLOUR.YELLOW
	elif(result == 1):
		s.load("res://test/sprites/flag orb blue.png")
		p2flag.colour = COLOUR.BLUE
	elif(result == 2):
		s.load("res://test/sprites/flagorbred.png")
		p2flag.colour = COLOUR.RED
	elif(result == 3):
		s.load("res://test/sprites/flag orb orange.png")
		p2flag.colour = COLOUR.ORANGE
	elif(result == 4):
		s.load("res://test/sprites/flag orb purple.png")
		p2flag.colour = COLOUR.PURPLE
	elif(result == 5):
		s.load("res://test/sprites/flag orb green.png")
		p2flag.colour = COLOUR.GREEN
	elif(result == 6):
		s.load("res://test/sprites/flag orb black.png")
		p2flag.colour = COLOUR.BLACK
	elif(result == 7):
		s.load("res://test/sprites/flag orb white.png")
		p2flag.colour = COLOUR.WHITE
	print("flag2 colour: " + str(p2flag.colour))
	p2flag.get_node("Sprite").get_texture().create_from_image(s)
	randomize()
	var p = randi() % 11
	add_child(p2flag)
	orbsonboard.push_back(p2flag)
	p2flag.set_pos(Vector2(960 + 33 + 70 + (70 * p),40 + 70 + 70 + 70 - (70 * Vector2(1.07337749,1.8417709).normalized().y)))
