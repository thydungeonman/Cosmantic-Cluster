extends Node2D

const NONE = "res://test/scenes/orb.tscn"
const YELLOW = "res://test/scenes/yelloworb.tscn"
const BLUE = "res://test/scenes/blueorb.tscn"
const ORANGE = "res://test/scenes/orangeorb.tscn"
const PURPLE = "res://test/scenes/purpleorb.tscn"
const BLACK = "res://test/scenes/blackorb.tscn"
const GREEN = "res://test/scenes/greenorb.tscn"
const WHITE = "res://test/scenes/whiteorb.tscn"
const RED = "res://test/scenes/redorb.tscn"


var player = 1

var trajectory = Vector2(-1500,-1500)
var x = 0.14 #starting angle of launcher

var upperlimit = PI - 0.14
var lowerlimit = 0.14

var rightpress = false
var leftpress = false

var shottimer = 0.0 #goes up to half a second then loads another orb into the launcher
var firing = false
var loaded = false
var orb
var storing = false
var swapping = false

onready var aim = get_node("Particles2D")
onready var container = get_node("container")

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
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
			orb.set_pos(get_global_pos())
			get_parent().orbsonboard.push_front(orb)
			loaded = true
			print("loaded new orb")
		else:
			GetFireControls(delta)
		
	GetAimControls(delta)


func GetAimControls(delta):
	
	if(Input.is_action_pressed("p1_aim_left")):
		x -= PI/170
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)
	elif(Input.is_action_pressed("p1_aim_right")):
		x += PI/170
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)

func GetFireControls(delta):
	if(Input.is_action_pressed("p1_fire") and loaded == true): #if the key is pressed and the launcher is loaded
		if(firing == false):
			Fire()
			firing = true
			loaded = false
			shottimer = 0.0
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
	
	if(Input.is_action_pressed("p1_swap") and !container.IsEmpty()):
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
			print(str(orb))
	else:
		swapping = false

func Fire():
	print(str(orb))
	orb.trajectory.x = trajectory.x * cos(x)
	orb.trajectory.y = trajectory.y * sin(x)
	orb.ismoving = true
	