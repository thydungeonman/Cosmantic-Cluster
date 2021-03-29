extends Node2D

var day = 0


var pastfountain = false
var atfountain = false
var wentmountian = false #false means went mansion
onready var enafountain = get_node("ena to fountain/PathFollow2D")
onready var fountainmountain = get_node("fountain to mountain/PathFollow2D")
onready var fountainmansion = get_node("fountain to mansion/PathFollow2D")
onready var player = get_node("ena to fountain/PathFollow2D/player")
onready var camera = get_node("ena to fountain/PathFollow2D/player/Camera2D")
var positionroute = 0 # route currently on
var positionpath = 0 #level in the route currently on
var fountainlevels = {0:0,1:1}
var mountainlevels = {0:.255,1:.3821,2:.663,3:.8206,4:.942,5:1}
var mansionlevels = {0:.0958,1:.1765,2:.3588,3:.6131,4:.7774,5:1}
var moving = false
var waittimer = 0
var selectedroute = 0
var selectedlevel = 0
var routes = [[0,1],[0,1,2,3,4,5],[0,1,2,3,4,5]]
var goaround = 0
var pressing = false

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	
	if(Input.is_action_pressed("ui_select")):
		if(!pressing):
			pressing = true
			if(camera.is_current()):
				camera.clear_current()
				get_node("worldcamera").make_current()
				
			else:
				camera.make_current()
	else:
		pressing = false
	
	
	if(!moving):
		waittimer += delta
		if waittimer > .5:
			DoLevel()
			waittimer = 0
	else:
		Move(selectedroute,positionpath,delta)
#		print(enafountain.get_unit_offset())


func Move(route,level,delta):
	if(route == 0):
		enafountain.set_offset(enafountain.get_offset() + (delta * 100))
		if(GiveOrTake(.012,fountainlevels[level],enafountain.get_unit_offset()) ):
			moving = false
			pass
	elif(route == 1):
		fountainmountain.set_offset(fountainmountain.get_offset() + (delta * 100))
		if(GiveOrTake(.002,mountainlevels[level],fountainmountain.get_unit_offset()) ):
			moving = false
	elif(route == 2):
		fountainmansion.set_offset(fountainmansion.get_offset() + (delta * 100))
		if(GiveOrTake(.002,mansionlevels[level],fountainmansion.get_unit_offset()) ):
			moving = false

func GiveOrTake(amount,target,num):
	return(num < (target + amount) and num > (target - amount))

func DoLevel():
	moving = true
	positionpath += 1
	if(positionpath > routes[selectedroute].size() - 1):
		if(selectedroute == 0 and goaround == 0):
			#ask player to pick route
			print("HELLLLLLLOW")
			selectedroute = 1
			positionpath = 0
			enafountain.remove_child(player)
			fountainmountain.add_child(player)
			player.set_pos(Vector2())
		elif(selectedroute == 0 and goaround == 1):
			selectedroute = 2
			positionpath = 0
			enafountain.remove_child(player)
			fountainmansion.add_child(player)
			fountainmountain.set_unit_offset(0)
			player.set_pos(Vector2())
		elif(selectedroute == 1):
			selectedroute = 0
			goaround = 1
			positionpath = 0
			enafountain.set_unit_offset(0)
			fountainmountain.remove_child(player)
			enafountain.add_child(player)
			player.set_pos(Vector2())
			pass
			#end day do next path
			#if finished both paths load next map
		elif(selectedroute == 2):
			selectedroute = 0
			goaround = 0
			positionpath = 0
			enafountain.set_unit_offset(0)
			fountainmansion.remove_child(player)
			enafountain.add_child(player)
			player.set_pos(Vector2())
			fountainmansion.set_unit_offset(0)
	else:
		#reveal next level