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
onready var aim = get_node("Particles2D")

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
		else:
			GetFireControls(delta,orb)
		
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

func GetFireControls(delta,orb):
	if(Input.is_action_pressed("p1_fire") and loaded == true): #if the key is pressed and the launcher is loaded
		if(firing == false):
			Fire(orb)
			firing = true
			loaded = false
			shottimer = 0.0
	else:
		firing = false

func Fire(orb):
	orb.trajectory.x = trajectory.x * cos(x)
	orb.trajectory.y = trajectory.y * sin(x)
	orb.ismoving = true
	