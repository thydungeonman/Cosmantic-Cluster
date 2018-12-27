extends Node2D
#TODO having a launcher with separate functions for p1 and p2 is inelegant
#the problem is how to use the same function but being able to wire
# it up to different controls

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

var player = PLAYER.PLAYER1

var trajectory = Vector2(-1500,-1500)
var x = (PI)/2 #starting angle of launcher
var speed = PI/170

var upperlimit = PI - 0.14
var lowerlimit = 0.14

var rightpress = false
var leftpress = false

var shottimer = 0.0 #goes up to half a second then loads another orb into the launcher
var canshoot = true
var firing = false
var loaded = false
var orb
var storing = false
var swapping = false 
var swapped = false #the player can only swap once

var ischarged = false

var isfrozen = false #has an enemies white ability been activated?
var frozentime = 1.00
var frozentimer = 0.00

onready var aim = get_node("Particles2D")
onready var container = get_node("container")

func _ready():
	set_fixed_process(true)
	aim.set_param(0,270 - rad2deg(x))


func _fixed_process(delta):
	LoadOrb(delta)
	if(player == PLAYER.PLAYER1):
		GetAimControlsP1(delta)
	if(player == PLAYER.PLAYER2):
		GetAimControlsP2(delta)
	if(isfrozen):
		Defrost(delta)

func LoadOrb(delta):
	shottimer += delta
	if(shottimer > .5):
		if(loaded == false):
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
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())#set the orb to launcher position
			get_parent().orbsonboard.push_front(orb)
			if(player == PLAYER.PLAYER1):
				orb.player = orb.PLAYER.PLAYER1
			if(player == PLAYER.PLAYER2):
				orb.player = orb.PLAYER.PLAYER2
			loaded = true
			orb.inlauncher = true
			print("loaded new orb")
		else:
			if(player == PLAYER.PLAYER1):
				GetFireControlsP1(delta)
			if(player == PLAYER.PLAYER2):
				GetFireControlsP2(delta)

func GetAimControlsP1(delta):
	if(Input.is_action_pressed("p1_aim_left")):
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)
	elif(Input.is_action_pressed("p1_aim_right")):
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)

func GetAimControlsP2(delta):
	if(Input.is_action_pressed("p2_aim_left")):
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)
	elif(Input.is_action_pressed("p2_aim_right")):
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)


func GetFireControlsP1(delta):
	if(Input.is_action_pressed("p1_fire") and loaded == true): #if the key is pressed and the launcher is loaded
		if(!firing and canshoot):
			Fire()
			firing = true
			loaded = false
			shottimer = 0.0
			Disable()
	else:
		firing = false
	if(Input.is_action_pressed("p1_store") and !container.IsFull()):
		if(storing == false):
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			container.TakeOrb(orb)
			loaded = false
			storing = true
	else:
		storing = false
	
	if(Input.is_action_pressed("p1_swap") and !container.IsEmpty() and !swapped):
		if(swapping == false):
			print(str(orb))
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			orb = container.Swap(orb)
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())
			get_parent().orbsonboard.push_front(orb)
			swapping = true
			swapped = true
			print(str(orb))
	else:
		swapping = false

func GetFireControlsP2(delta):
	if(Input.is_action_pressed("p2_fire") and loaded == true): #if the key is pressed and the launcher is loaded
		if(!firing and canshoot):
			Fire()
			firing = true
			loaded = false
			shottimer = 0.0
			Disable()
	else:
		firing = false
	if(Input.is_action_pressed("p2_store") and !container.IsFull()):
		if(storing == false):
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			container.TakeOrb(orb)
			loaded = false
			storing = true
	else:
		storing = false
	
	if(Input.is_action_pressed("p2_swap") and !container.IsEmpty() and !swapped):
		if(swapping == false):
			print(str(orb))
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			orb = container.Swap(orb)
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())
			get_parent().orbsonboard.push_front(orb)
			swapping = true
			swapped = true
			print(str(orb))
	else:
		swapping = false


func Fire():
	# if yellow ablility = true
	# spawn lightning area and child to orb
	# when orb stops check bool in orb and then activate lightning
	print(str(orb))
	orb.trajectory.x = trajectory.x * cos(x)
	orb.trajectory.y = trajectory.y * sin(x)
	orb.ismoving = true
	orb.inlauncher = false
	if(ischarged):
		orb.Charge()
		ischarged = false
	swapped = false

func Freeze():
	isfrozen = true
	speed = 0

func Defrost(delta):
	frozentimer += delta
	if(frozentimer >= frozentime):
		speed = PI/170
		isfrozen = false
		frozentimer = 0.00

func Charge():
	ischarged = true

func Enable():
	canshoot = true
func Disable():
	canshoot = false