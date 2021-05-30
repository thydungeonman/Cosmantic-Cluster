extends "res://test/scripts/aiboard.gd"
enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

enum GC {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,RAND = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9, BLANKROW = 10,FLAG = 11}
const NONE = "res://test/scenes/orb.tscn"
const YELLOW = "res://test/scenes/yelloworb.tscn"
const BLUE = "res://test/scenes/blueorb.tscn"
const ORANGE = "res://test/scenes/orangeorb.tscn"
const PURPLE = "res://test/scenes/purpleorb.tscn"
const BLACK = "res://test/scenes/blackorb.tscn"
const GREEN = "res://test/scenes/greenorb.tscn"
const WHITE = "res://test/scenes/whiteorb.tscn"
const RED = "res://test/scenes/redorb.tscn"

var p1flagspot
var p2flagspot

var partner = "res://test/stages/6-2-2.tscn"

var genavailablecolours = [GC.RED,GC.GREEN,GC.BLUE,GC.YELLOW,GC.ORANGE,GC.PURPLE]
var launcheravailablecolours = [COLOUR.RED,COLOUR.GREEN,COLOUR.BLUE,COLOUR.YELLOW,GC.ORANGE,GC.PURPLE]
var board = [
 #12 2
[GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.FLAG,GC.RAND], #13 3
[GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND] #12 4
,[GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND] #13 5
,[GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND] #12 6
,[GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND] #13 7
,[GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND] #12 8
,[GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND] #13 9
,[GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND] #12 10
,[GC.RAND,GC.RAND,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.NONE,GC.NONE,GC.NONE,GC.RAND,GC.RAND,GC.RAND] #13 11
,[GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.RAND] #12 12
,[GC.PURPLE,GC.PURPLE,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.PURPLE,GC.RAND,GC.RAND,GC.RAND,GC.RAND,GC.PURPLE,GC.PURPLE] #13 13
,[GC.BLANKROW] #12 14
,[GC.BLANKROW]
,[GC.BLANKROW]
]

func _ready():
	
	p1launcher.availablecolours = launcheravailablecolours
	p2launcher.availablecolours = launcheravailablecolours
	print(orbsonboard.size())
	print(orbsonboardp1.size())
	print(orbsonboardp2.size())
	get_node("p1deathline").translate(Vector2(0,-15))
	get_node("p2deathline").translate(Vector2(0,-15))

func GenerateBoardP1():
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 35 + 17
	var yoffset = 40 + (70 * 1)
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	var orbwidth = startorb.width
	
	startorb.queue_free()
	
	for i in range(board.size()):
		pass
		if(i%2 == 1):
			GenerateEvenRow(xoffset + 35,yoffset,orbwidth,PLAYER.PLAYER1,board[i])
		else:
			GenerateEvenRow(xoffset,yoffset,orbwidth,PLAYER.PLAYER1,board[i])
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;

func GenerateBoardP2():
	var startorb = preload("res://test/scenes/orb.tscn").instance()
	var xoffset = 960 + 68
	var yoffset = 40 + (70 * 1)
	add_child(startorb)
	startorb.set_pos(Vector2(70 + 70,100))
	var orbwidth = startorb.width
	
	startorb.queue_free()
	
	for i in range(board.size()):
		pass
		if(i%2 == 1):
			GenerateEvenRow(xoffset + 35,yoffset,orbwidth,PLAYER.PLAYER2,board[i])
		else:
			GenerateEvenRow(xoffset,yoffset,orbwidth,PLAYER.PLAYER2,board[i])
		yoffset += orbwidth * Vector2(1.07337749,1.8417709).normalized().y;

func GenerateEvenRow(xoffset,yoffset,width,player,row):
	for i in range(row.size()):
		var orb
		if(row[i] == GC.NONE):
			continue
		elif(row[i] == GC.BLANKROW):
			return
		elif(row[i] == GC.RAND):
			randomize()
			var rand = randi() % genavailablecolours.size()
			orb = GenerateOrb(orb,genavailablecolours[rand])
		elif(row[i] == GC.FLAG):
			if(player == PLAYER.PLAYER1):
				p1flagspot = Vector2(xoffset + width*i,yoffset)
			else:
				p2flagspot = Vector2(xoffset + width*i,yoffset)
			continue
		else:
			orb = GenerateOrb(orb,row[i])
		
		add_child(orb)
		orb.set_pos(Vector2(xoffset + width*i, yoffset))
		if(player == 0):
			orb.player = orb.PLAYER.PLAYER1
			orb.onboard = orb.PLAYER.PLAYER1
			orbsonboardp1.push_front(orb)
		elif(player == 1):
			orb.player = orb.PLAYER.PLAYER2
			orb.onboard = orb.PLAYER.PLAYER2
			orbsonboardp2.push_front(orb)
		orbsonboard.push_front(orb)

func GenerateOddRow():
	pass

func GenerateOrb(orb,gencolour):
	if(gencolour == GC.BLACK):
		orb = preload(BLACK).instance()
	if(gencolour == GC.BLUE):
		orb = preload(BLUE).instance()
	if(gencolour == GC.GREEN):
		orb = preload(GREEN).instance()
	if(gencolour == GC.ORANGE):
		orb = preload(ORANGE).instance()
	if(gencolour == GC.PURPLE):
		orb = preload(PURPLE).instance()
	if(gencolour == GC.RED):
		orb = preload(RED).instance()
	if(gencolour == GC.WHITE):
		orb = preload(WHITE).instance()
	if(gencolour == GC.YELLOW):
		orb = preload(YELLOW).instance()
	return orb


func GeneratePlayer1Flag():
	p1flag = preload("res://test/scenes/flagorb.tscn").instance()
	var s = Image()
	
	randomize()
	var rand = randi() % genavailablecolours.size()
	var result = genavailablecolours[rand]
	if(result == GC.YELLOW):
		s.load(YELLOWFLAG)
		p1flag.colour = COLOUR.YELLOW
	elif(result == GC.BLUE):
		s.load(BLUEFLAG)
		p1flag.colour = COLOUR.BLUE
	elif(result == GC.RED):
		s.load(REDFLAG)
		p1flag.colour = COLOUR.RED
	elif(result == GC.ORANGE):
		s.load(ORANGEFLAG)
		p1flag.colour = COLOUR.ORANGE
	elif(result == GC.PURPLE):
		s.load(PURPLEFLAG)
		p1flag.colour = COLOUR.PURPLE
	elif(result == GC.GREEN):
		s.load(GREENFLAG)
		p1flag.colour = COLOUR.GREEN
	elif(result == GC.BLACK):
		s.load(BLACKFLAG)
		p1flag.colour = COLOUR.BLACK
	elif(result == GC.WHITE):
		s.load(WHITEFLAG)
		p1flag.colour = COLOUR.WHITE
	print("flag1 colour: " + str(p1flag.colour))
	p1flag.get_node("Sprite").get_texture().create_from_image(s)
	randomize()
	var p = randi() % 11
	add_child(p1flag)
	orbsonboard.push_back(p1flag)
#	p1flag.set_pos(Vector2(17 + 70 + (70 * p),40 + 70 + 70 + 70 - (70 * Vector2(1.07337749,1.8417709).normalized().y)))
	p1flag.set_pos(p1flagspot)
	print(p1flag.get_pos())
	print("flag pos")


func GeneratePlayer2Flag():
	p2flag = preload("res://test/scenes/flagorb2.tscn").instance()
	var s = Image()
	
	randomize()
	var rand = randi() % genavailablecolours.size()
	var result = genavailablecolours[rand]
	if(result == GC.YELLOW):
		s.load(YELLOWFLAG)
		p2flag.colour = COLOUR.YELLOW
	elif(result == GC.BLUE):
		s.load(BLUEFLAG)
		p2flag.colour = COLOUR.BLUE
	elif(result == GC.RED):
		s.load(REDFLAG)
		p2flag.colour = COLOUR.RED
	elif(result == GC.ORANGE):
		s.load(ORANGEFLAG)
		p2flag.colour = COLOUR.ORANGE
	elif(result == GC.PURPLE):
		s.load(PURPLEFLAG)
		p2flag.colour = COLOUR.PURPLE
	elif(result == GC.GREEN):
		s.load(GREENFLAG)
		p2flag.colour = COLOUR.GREEN
	elif(result == GC.BLACK):
		s.load(BLACKFLAG)
		p2flag.colour = COLOUR.BLACK
	elif(result == GC.WHITE):
		s.load(WHITEFLAG)
		p2flag.colour = COLOUR.WHITE
	print("flag1 colour: " + str(p2flag.colour))
	p2flag.get_node("Sprite").get_texture().create_from_image(s)
	randomize()
	var p = randi() % 11
	add_child(p2flag)
	orbsonboard.push_back(p2flag)
#	p2flag.set_pos(Vector2(960 + 33 + 70 + (70 * p),40 + 70 + 70 + 70 - (70 * Vector2(1.07337749,1.8417709).normalized().y)))
	p2flag.set_pos(p2flagspot)
	print(p2flag.get_pos())
	print("flag pos")
	
func Win():
	get_tree().change_scene(partner)