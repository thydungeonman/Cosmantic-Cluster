extends Node2D

var trajectory = Vector2(-1500,-1500)
var x = 0.14

var upperlimit = PI - 0.14
var lowerlimit = 0.14

var rightpress = false
var leftpress = false
var firing = false

onready var aim = get_node("Particles2D")

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	GetControls(delta)


func GetControls(delta):
	
	if(Input.is_action_pressed("ui_left")):
		x -= PI/170
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)
	elif(Input.is_action_pressed("ui_right")):
		x += PI/170
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		#print(x)
	if(Input.is_action_pressed("fire")):
		if(firing == false):
			var orb = preload("res://test/scenes/yelloworb.tscn").instance()
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())
			Fire(orb)
			firing = true
	else:
		firing = false

func Fire(orb):
	orb.trajectory.x = trajectory.x * cos(x)
	orb.trajectory.y = trajectory.y * sin(x)
	orb.ismoving = true
	