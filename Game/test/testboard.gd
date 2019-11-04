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
onready var anim = get_node("AnimationPlayer")
onready var animenap1 = get_node("enaplayer")
onready var animenap2 = get_node("enaP2player")

var numthatfit = 13 #((get_viewport_rect().size.x)/2) / startorb.width+



var fallcheckarray = []
var orbsonboard = [] 
var orbsonboardp1 = [] #if either is empty, the game is over
var orbsonboardp2 = [] 
var s = false 
var t  = 0.0 #timer variable to delay the raycasts of the orbs when generated, works with s

var leftoverorbs = []
var crossreforbs = []
var orb; #the newest orb

onready var p1launcher = get_node("p1launcher")
var p2launcher = null

var p1flag #flag orbs
var p2flag

var player1health = 5
var player2health = 5
var lastusedcolourp1 = COLOUR.NONE
var lastusedcolourp2 = COLOUR.NONE
var abilitycombop1 = 0 #counts the number of times a color is chained
var abilitycombop2 = 0
var p1isnegated = false # these are for when a player has their next ability negated by a purple ability
var p2isnegated = false
onready var p1abilitylabel = get_node("p1combo")
onready var p2abilitylabel = get_node("p2combo")

var p1isdark = false
var p1darktime = 5.00
var p1darktimer = 0.00
var p2isdark = false
var p2darktime = 5.00 #time that the darkness ability lasts
var p2darktimer = 0.00 #timer that counts how long the darkness has gone for

var timerpaused = false
var timerlockout = false

#test
onready var ray = get_node("RayCast2D")
var rclick = false

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
		var p1 = 0
		var p2 = 0
		for orb in orbsonboard:
			if orb.player == PLAYER.PLAYER1:
				p1 += 1;
			else:
				p2 += 1
#		print("player one orbs: " + str(p1))
#		print("player two orbs: " + str(p2))
		print("player one available spot: " + str(FindAvailableSpot(PLAYER.PLAYER1)))
		print("player two available spot: " + str(FindAvailableSpot(PLAYER.PLAYER2)))
	
#	if(Input.is_action_pressed("click")):
#		Click()
	if(Input.is_action_pressed("rclick")):
		if(rclick == false):
			RClick()
			rclick = true
	else:
		rclick = false
	
	#for whatever reason the physics of the orbs does not work as soon as theyre ready
	#so we will wait for a half second for them to find their neighbors
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
	p2launcher.set_pos(Vector2(1447,980))

func GenerateP1Launcher():
	var launcher = preload("res://test/scenes/launcher.tscn").instance()
	add_child(launcher)
	launcher.player = launcher.PLAYER.PLAYER1
	launcher.set_pos(Vector2(465,1040))

func HandleAbilityCombo(colour,player):
	var combo = 0
	print(str(lastusedcolourp1))
	if(player == PLAYER.PLAYER1):
		if(lastusedcolourp1 == colour or lastusedcolourp1 == COLOUR.BLUE):
			print("same colour or blue")
			abilitycombop1 += 1
		else:
			if(lastusedcolourp1 != COLOUR.NONE):
				NewHandleAbility(player)
			lastusedcolourp1 = colour
			abilitycombop1 = 1
			
			combo = abilitycombop1
		if(lastusedcolourp1 != COLOUR.BLUE):
			if(colour == COLOUR.BLACK):
				get_node("p1combo").set_text("BLACK ABILITY X")
			elif(colour == COLOUR.BLUE):
				get_node("p1combo").set_text("BLUE ABILITY X")
			elif(colour == COLOUR.GREEN):
				get_node("p1combo").set_text("GREEN ABILITY X")
			elif(colour == COLOUR.ORANGE):
				get_node("p1combo").set_text("ORANGE ABILITY X")
			elif(colour == COLOUR.PURPLE):
				get_node("p1combo").set_text("PURPLE ABILITY X")
			elif(colour == COLOUR.RED):
				get_node("p1combo").set_text("RED ABILITY X")
			elif(colour == COLOUR.WHITE):
				get_node("p1combo").set_text("WHITE ABILITY X")
			elif(colour == COLOUR.YELLOW):
				get_node("p1combo").set_text("YELLOW ABILITY X")
		else:
			get_node("p1combo").set_text("BLUE ABILITY X")
		get_node("p1combo").set_text(get_node("p1combo").get_text() + str(abilitycombop1))
	elif(player == PLAYER.PLAYER2):
		if(lastusedcolourp2 == colour or lastusedcolourp2 == COLOUR.BLUE):
			abilitycombop2 += 1
		else:
			if(lastusedcolourp2 != COLOUR.NONE):
				NewHandleAbility(player)
			abilitycombop2 = 1
			lastusedcolourp2 = colour
			combo = abilitycombop2
		if(lastusedcolourp2 != COLOUR.BLUE):
			if(colour == COLOUR.BLACK):
				get_node("p2combo").set_text("BLACK ABILITY X")
			elif(colour == COLOUR.BLUE):
				get_node("p2combo").set_text("BLUE ABILITY X")
			elif(colour == COLOUR.GREEN):
				get_node("p2combo").set_text("GREEN ABILITY X")
			elif(colour == COLOUR.ORANGE):
				get_node("p2combo").set_text("ORANGE ABILITY X")
			elif(colour == COLOUR.PURPLE):
				get_node("p2combo").set_text("PURPLE ABILITY X")
			elif(colour == COLOUR.RED):
				get_node("p2combo").set_text("RED ABILITY X")
			elif(colour == COLOUR.WHITE):
				get_node("p2combo").set_text("WHITE ABILITY X")
			elif(colour == COLOUR.YELLOW):
				get_node("p2combo").set_text("YELLOW ABILITY X")
		else:
			get_node("p2combo").set_text("BLUE ABILITY X")
		get_node("p2combo").set_text(get_node("p2combo").get_text() + str(abilitycombop2))
	print("colour: " + str(colour) + " combo: " +  str(abilitycombop2))
	return combo

func NewHandleAbility(player):
	
	print("activating combo")
	
	if(player == PLAYER.PLAYER1):
		if(lastusedcolourp1 == COLOUR.BLACK): #comboable
			p2darktime = abilitycombop1 * 3
			if(abilitycombop1 > 2):
				p2darktime += (abilitycombop1 - 2)
			get_node("p2darkness").set_hidden(false)
			p2isdark = true
			animenap1.play("ena attack")
		elif(lastusedcolourp1 == COLOUR.BLUE): #comboable
			if(abilitycombop1 > 8):
				abilitycombop1 = 8
			var times = abilitycombop1 * 3
			if(abilitycombop1 == 1):
				times -=2
			elif(abilitycombop1 == 2):
				times -= 3
			else:
				times -= 4
			
			for i in range(times):
				P1BlueAbility()
			animenap1.play("ena attack")
		elif(lastusedcolourp1 == COLOUR.GREEN): #comboable
			if(abilitycombop1 > 8):
				abilitycombop1 = 8
			var increase = abilitycombop1*3
			if(abilitycombop1 == 1 || abilitycombop1 == 7):
				increase -= 2
			elif(abilitycombop1 == 2 || abilitycombop1 == 6):
				increase -= 3
			elif(abilitycombop1 == 8):
				increase -= 1
			else:
				increase -= 4
			
			player1health += increase
			print("Player 1 health: " + str(player1health))
			UpdateHealthLabels()
			sfx.play("another-magic-wand-spell-tinkle - Green ability used Hp Gain")
			p1launcher.HealAnim()
		elif(lastusedcolourp1 == COLOUR.ORANGE):
			p1launcher.ActivateLaser()
		elif(lastusedcolourp1 == COLOUR.PURPLE):
			lastusedcolourp2 = COLOUR.NONE
			abilitycombop2 = 0
			get_node("p2combo").set_text("NONE ABILITY X0")
			sfx.play("moved-02-dark - Purple ability used")
			anim.play("p1purpleability")
			animenap1.play("ena attack")
		elif(lastusedcolourp1 == COLOUR.RED): #comboable
			print("red combo activated")
			
			if(abilitycombop1 > 8):
				abilitycombop1 = 8
			var increase = abilitycombop1*3
			if(abilitycombop1 == 1 || abilitycombop1 == 8):
				increase -= 2
			elif(abilitycombop1 == 2 || abilitycombop1 == 7):
				increase -= 3
			else:
				increase -= 4
			player2health -= increase
			
			UpdateHealthLabels()
			sfx.play("fireworks-mortar - Red ability used Hp loss")
			p2launcher.DamageAnim()
			animenap1.play("ena attack")
			animenap2.play("enap2 damage")
			print(increase)
			IsPlayerDead()
		elif(lastusedcolourp1 == COLOUR.WHITE): #comboable
			if(abilitycombop1 > 8):
				abilitycombop1 = 8
				
			var freezetime = abilitycombop1 * 3
			if(abilitycombop1 == 6):
				freezetime += 1
			elif(abilitycombop1 == 7):
				freezetime += 2
			elif(abilitycombop1 == 8):
				freezetime += 4
			
			var tier = floor(abilitycombop1/2.0)
			if(abilitycombop1 == 3):
				tier = 2.0
			if(abilitycombop1 == 1):
				tier = 1.0
			print(tier)
			p2launcher.Freeze(freezetime,tier)
			
			sfx.play("winter wind - White ability used")
			animenap1.play("ena attack")
		elif(lastusedcolourp1 == COLOUR.YELLOW):
			p1launcher.Charge()
			if(p1isdark):
				p1darktimer = p1darktime
				#p1isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		lastusedcolourp1 = COLOUR.NONE
		abilitycombop1 = 0
		get_node("p1combo").set_text("NONE ABILITY X0")
	
	elif(player == PLAYER.PLAYER2):
		if(lastusedcolourp2 == COLOUR.BLACK): #comboable
			p1darktime = abilitycombop2 * 3
			if(abilitycombop2 > 2):
				p1darktime += (abilitycombop2 - 2)
			get_node("p1darkness").set_hidden(false)
			p1isdark = true
			animenap2.play("enap2 attack")
		elif(lastusedcolourp2 == COLOUR.BLUE): #comboable
			if(abilitycombop2 > 8):
				abilitycombop2 = 8
			var times = abilitycombop2 * 3
			if(abilitycombop2 == 1):
				times -=2
			elif(abilitycombop2 == 2):
				times -= 3
			else:
				times -= 4
			
			for i in range(times):
				P2BlueAbility()
			animenap2.play("enap2 attack")
		elif(lastusedcolourp2 == COLOUR.GREEN): #comboable
			
			if(abilitycombop2 > 8):
				abilitycombop2 = 8
			var increase = abilitycombop2*3
			if(abilitycombop2 == 1 || abilitycombop2 == 7):
				increase -= 2
			elif(abilitycombop2 == 2 || abilitycombop2 == 6):
				increase -= 3
			elif(abilitycombop2 == 8):
				increase -= 1
			else:
				increase -= 4
			
			player2health += increase
			print("Player 2 health: " + str(player2health))
			UpdateHealthLabels()
			sfx.play("another-magic-wand-spell-tinkle - Green ability used Hp Gain")
			p2launcher.HealAnim()
		elif(lastusedcolourp2 == COLOUR.ORANGE):
			p2launcher.ActivateLaser()
		elif(lastusedcolourp2 == COLOUR.PURPLE):
			lastusedcolourp1 = COLOUR.NONE
			abilitycombop1 = 0
			get_node("p1combo").set_text("NONE ABILITY X0")
			sfx.play("moved-02-dark - Purple ability used")
			anim.play("p2purpleability")
			animenap2.play("enap2 attack")
		elif(lastusedcolourp2 == COLOUR.RED): #comboable
			print("red combo activated")
			
			if(abilitycombop2 > 8):
				abilitycombop2 = 8
			var increase = abilitycombop2*3
			if(abilitycombop2 == 1 || abilitycombop2 == 8):
				increase -= 2
			elif(abilitycombop2 == 2 || abilitycombop2 == 7):
				increase -= 3
			else:
				increase -= 4
			player1health -= increase
			UpdateHealthLabels()
			sfx.play("fireworks-mortar - Red ability used Hp loss")
			p1launcher.DamageAnim()
			animenap1.play("ena damage")
			animenap2.play("enap2 attack")
			IsPlayerDead()
		elif(lastusedcolourp2 == COLOUR.WHITE): #comboable
			if(abilitycombop2 > 8):
				abilitycombop2 = 8
				
			var freezetime = abilitycombop2 * 3
			if(abilitycombop2 == 6):
				freezetime += 1
			elif(abilitycombop2 == 7):
				freezetime += 2
			elif(abilitycombop2 == 8):
				freezetime += 4
			
			var tier = floor(abilitycombop2/2.0)
			if(abilitycombop2 == 3):
				tier = 2.0
			if(abilitycombop2 == 1):
				tier = 1.0
			print(tier)
			p1launcher.Freeze(freezetime,tier)
			sfx.play("winter wind - White ability used")
			animenap2.play("enap2 attack")
		elif(lastusedcolourp2 == COLOUR.YELLOW):
			p2launcher.Charge()
			if(p2isdark):
				p2darktimer = p2darktime
				#p2isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		lastusedcolourp2 = COLOUR.NONE
		abilitycombop2 = 0
		get_node("p2combo").set_text("NONE ABILITY X0")
	



func HandleAbility(colour,player):
	print(str(colour))
	print("activating ablity")
	
	if(player == PLAYER.PLAYER1 and !p1isnegated):
		if(colour == COLOUR.RED):
			player2health -= 1
			p2launcher.get_node("health").set_text("Health " + str(player2health))
			sfx.play("fireworks-mortar - Red ability used Hp loss")
			p1abilitylabel.set_text("RED ABILITY")
		if(colour == COLOUR.GREEN):
			player1health += 1
			print("Player 1 health: " + str(player1health))
			p1launcher.get_node("health").set_text("Health " + str(player1health))
			sfx.play("another-magic-wand-spell-tinkle - Green ability used Hp Gain")
			p1abilitylabel.set_text("GREEN ABILITY")
		if(colour == COLOUR.BLACK):
			get_node("p2darkness").set_hidden(false)
			p2isdark = true
			sfx.play("dark magic loop - Black ability used")
			p1abilitylabel.set_text("BLACK ABILITY")
		if(colour == COLOUR.WHITE):
			p2launcher.Freeze()
			sfx.play("winter wind - White ability used")
			p1abilitylabel.set_text("WHITE ABILITY")
		if(colour == COLOUR.YELLOW):
			p1launcher.Charge()
			if(p1isdark):
				p1darktimer = p1darktime
				#p1isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		if(colour == COLOUR.BLUE):
			P1BlueAbility()
			sfx.play("billiard-balls-single-hit-dry - Grey orbs spawn")
		if(colour == COLOUR.PURPLE):
			p2isnegated = true
			get_node("p2combo").set_text("NONE ABILITY X0")
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
			p1launcher.Freeze(1.0)
			sfx.play("winter wind - White ability used")
		if(colour == COLOUR.YELLOW):
			p2launcher.Charge()
			if(p2isdark):
				p2darktimer = p2darktime
				#p2isdark = false
				sfx.play("008-mercury-sparkle - yellow ability clearing darkness")
		if(colour == COLOUR.BLUE):
			P2BlueAbility()
			sfx.play("billiard-balls-single-hit-dry - Grey orbs spawn")
		if(colour == COLOUR.PURPLE):
			p1isnegated = true
			sfx.play("moved-02-dark - Purple ability used")
			get_node("p1combo").set_text("NONE ABILITY X0")
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
		p2darktime = 1.0

func P2BlackAbility(delta):
	p1darktimer += delta
	if(p1darktimer >= p1darktime):
		get_node("p1darkness").set_hidden(true)
		p1isdark = false
		p1darktimer = 0.0
		p1darktime = 1.0

func P1BlueAbility():
	
	var orb = FindAvailableSpot(PLAYER.PLAYER2)
	if(orb == null):
		return #couldn't find an orb. bail out
	else:
		var grey = preload("res://test/scenes/greyorb.tscn").instance()
		add_child(grey)
		if(orb.touchingwallright):
			grey.set_pos(orb.bottomleftspot)
		elif(orb.touchingwallleft):
			grey.set_pos(orb.bottomrightspot)
		else:
			if(orb.bottomright == null):
				grey.set_pos(orb.bottomrightspot)
			elif(orb.bottomleft == null):
				grey.set_pos(orb.bottomleftspot)
		grey.HookUp()
		grey.player = PLAYER.PLAYER2
		orbsonboard.push_back(grey)

func P2BlueAbility():
	var orb = FindAvailableSpot(PLAYER.PLAYER1)
	if(orb == null):
		return #couldn't find an orb. bail out
	else:
		var grey = preload("res://test/scenes/greyorb.tscn").instance()
		add_child(grey)
		if(orb.touchingwallright):
			grey.set_pos(orb.bottomleftspot)
		elif(orb.touchingwallleft):
			grey.set_pos(orb.bottomrightspot)
		else:
			if(orb.bottomright == null):
				grey.set_pos(orb.bottomrightspot)
			elif(orb.bottomleft == null):
				grey.set_pos(orb.bottomleftspot)
		grey.HookUp()
		grey.player = PLAYER.PLAYER1
		orbsonboard.push_back(grey)


#func Click():
#	#P2BlueAbility()
#	var mousepos = get_viewport().get_mouse_pos()
#	ray.set_cast_to(mousepos - ray.get_global_pos())
#	if(ray.get_collider() != null):
#		print(ray.get_collider().get_name())
#	var testorb = ray.get_collider()
#	if(testorb != null):
#		if(testorb.is_in_group("orb")):
#			var group = []
#			testorb.Search(1,COLOUR.NONE,group)
#			print(str(group.size()))
#	GameOver("ITS OVER",PLAYER.PLAYER1)

func RClick():
	P2BlueAbility()
	P2BlueAbility()
	P2BlueAbility()
	P1BlueAbility()
	P1BlueAbility()
	P1BlueAbility()
	#GameOver()
	pass

func FindAvailableSpot(player):
	#finds the first available spot for a gray orb to be spawned for the player that is passed to the function
	#usually that is the last orb that player fired
	var spot = null
	for orb in orbsonboard:
		if(orb.player == player and orb.ismoving == false):
			if(orb.CountNeighbors() < 6):
				if(orb.touchingwallleft == true and orb.bottomright != null):
					continue
				if(orb.touchingwallright == true and orb.bottomleft != null):
					continue
				if(orb.bottomright != null and orb.bottomleft != null):
					continue
				print(str(orb.get_name()))
				spot = orb
				break
	return spot

func GeneratePlayer1Flag():
	p1flag = preload("res://test/scenes/flagorb.tscn").instance()
	var s = Image()
	
	randomize()
	var result = randi() % 8
	if(result == 0):
		s.load("res://test/sprites/flag orb yellow new.png")
		p1flag.colour = COLOUR.YELLOW
	elif(result == 1):
		s.load("res://test/sprites/flag orb blue new.png")
		p1flag.colour = COLOUR.BLUE
	elif(result == 2):
		s.load("res://test/sprites/flag orb red new ver 2.png")
		p1flag.colour = COLOUR.RED
	elif(result == 3):
		s.load("res://test/sprites/flag orb orange new.png")
		p1flag.colour = COLOUR.ORANGE
	elif(result == 4):
		s.load("res://test/sprites/flag orb purple new.png")
		p1flag.colour = COLOUR.PURPLE
	elif(result == 5):
		s.load("res://test/sprites/flag orb green new.png")
		p1flag.colour = COLOUR.GREEN
	elif(result == 6):
		s.load("res://test/sprites/flag orb black new.png")
		p1flag.colour = COLOUR.BLACK
	elif(result == 7):
		s.load("res://test/sprites/flag orb white new.png")
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
		s.load("res://test/sprites/flag orb yellow new.png")
		p2flag.colour = COLOUR.YELLOW
	elif(result == 1):
		s.load("res://test/sprites/flag orb blue new.png")
		p2flag.colour = COLOUR.BLUE
	elif(result == 2):
		s.load("res://test/sprites/flag orb red new ver 2.png")
		p2flag.colour = COLOUR.RED
	elif(result == 3):
		s.load("res://test/sprites/flag orb orange new.png")
		p2flag.colour = COLOUR.ORANGE
	elif(result == 4):
		s.load("res://test/sprites/flag orb purple new.png")
		p2flag.colour = COLOUR.PURPLE
	elif(result == 5):
		s.load("res://test/sprites/flag orb green new.png")
		p2flag.colour = COLOUR.GREEN
	elif(result == 6):
		s.load("res://test/sprites/flag orb black new.png")
		p2flag.colour = COLOUR.BLACK
	elif(result == 7):
		s.load("res://test/sprites/flag orb white new.png")
		p2flag.colour = COLOUR.WHITE
	print("flag2 colour: " + str(p2flag.colour))
	p2flag.get_node("Sprite").get_texture().create_from_image(s)
	randomize()
	var p = randi() % 11
	add_child(p2flag)
	orbsonboard.push_back(p2flag)
	p2flag.set_pos(Vector2(960 + 33 + 70 + (70 * p),40 + 70 + 70 + 70 - (70 * Vector2(1.07337749,1.8417709).normalized().y)))


func Restart():
	for orb in orbsonboard:
		orb.queue_free()
	orbsonboard.clear()
	orbsonboardp1.clear()
	orbsonboardp2.clear()
	GenerateBoardP1()
	GenerateBoardP2()
	GeneratePlayer1Flag()
	GeneratePlayer2Flag()
	p1launcher.Reset()
	p2launcher.Reset()
	p1launcher.container.Reset()
	p2launcher.container.Reset()
	t = 0
	s = false
	player1health = 5
	player2health = 5
	UpdateHealthLabels()
	lastusedcolourp1 = COLOUR.NONE
	lastusedcolourp2 = COLOUR.NONE
	abilitycombop1 = 0
	abilitycombop2 = 0
	animenap1.play("ena idle")
	animenap2.play("enap2 idle")
	get_node("Timer").set_wait_time(300)
	get_node("Timer").set_active(true)
	get_node("Timer").start()
	
func UpdateHealthLabels():
	p1launcher.get_node("health").set_text("Health " + str(player1health))
	p2launcher.get_node("health").set_text("Health " + str(player2health))

func GameOver(gameoverstring,winner):
	if(winner == PLAYER.PLAYER1):
		print("one win")
		animenap1.play("ena win")
		animenap2.play("enap2 lose")
	elif(winner == PLAYER.PLAYER2):
		print("2 win")
		animenap1.play("ena lose")
		animenap2.play("enap2 win")
	else:
		animenap1.play("ena lose")
		animenap2.play("enap2 lose")
	get_node("screendim").set_hidden(false)
	get_node("replaybutton").set_hidden(false)
	get_node("gameoverlabel").set_text(gameoverstring)
	get_node("gameoverlabel").set_hidden(false)
	get_node("replaybutton").set_disabled(false)
	get_node("quitbutton").set_hidden(false)
	get_node("quitbutton").set_disabled(false)
	get_node("Timer").set_active(false)
	

func _on_replaybutton_pressed():
	get_node("screendim").set_hidden(true)
	get_node("replaybutton").set_hidden(true)
	get_node("gameoverlabel").set_hidden(true)
	get_node("replaybutton").set_disabled(true)
	get_node("quitbutton").set_hidden(true)
	get_node("quitbutton").set_disabled(true)
	Restart()


func _on_Timer_timeout():
	if(orbsonboardp1.size() < orbsonboardp2.size()):
		GameOver("Player One wins",PLAYER.PLAYER1)
	elif(orbsonboardp1.size() > orbsonboardp2.size()):
		GameOver("Player Two wins",PLAYER.PLAYER2)
	else:
		GameOver("Its a Draw",null)


func _on_Button_toggled( pressed ):
	if(pressed):
		get_node("Button").set_text("Unpause")
	else:
		get_node("Button").set_text("Pause")
	get_node("Timer").set_active(!pressed)

func IsPlayerDead():
	if(player1health < 1):
		GameOver("Player two wins",PLAYER.PLAYER2)
	elif(player2health < 1):
		GameOver("Player one wins",PLAYER.PLAYER1)

func CheckPlayerBoard(player):
	if(player == PLAYER.PLAYER1):
		if(orbsonboardp1.size() == 0):
			GameOver("Player One Wins!",PLAYER.PLAYER1)
	elif(player == PLAYER.PLAYER2):
		if(orbsonboardp2.size() == 0):
			GameOver("Player Two Wins!",PLAYER.PLAYER2)
