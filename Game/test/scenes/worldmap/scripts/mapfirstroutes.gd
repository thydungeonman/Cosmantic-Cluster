extends Node2D


#get approprate level to start at the right place
#each level should just have a beat button for testing

var day = 0


var pastfountain = false
var atfountain = false
var wentmountain = false #false means went mansion
onready var label = get_node("positionpath")
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
var selecting = false
var waittimer = 0
var selectedroute = 0
var selectedlevel = 0
var routes = [[0,1,2],[0,1,2,3,4,5,6],[0,1,2,3,4,5,6]]
var fountainstages = ["","res://test/stages/1-1-1.tscn","res://test/stages/2-1-1.tscn"] #maybe add black level at the start
var mountainstages = ["","res://test/stages/3-1-1.tscn","res://test/stages/4-1-1.tscn",
"res://test/stages/5-1-1.tscn","res://test/stages/6-1-1.tscn","res://test/stages/7-1-1.tscn",
"res://test/stages/8-1-1.tscn"]
var mansionstages =  ["","res://test/stages/3-2-1.tscn","res://test/stages/4-2-1.tscn",
"res://test/stages/5-2-1.tscn","res://test/stages/6-2-1.tscn","res://test/stages/7-2-1.tscn",
"res://test/stages/8-2-1.tscn"]
var goaround = 0
var pressing = false

onready var selectors = [get_node("ss0"),get_node("ss1"),get_node("ss2"),get_node("ss3"),get_node("ss4"),get_node("ss5"),
get_node("ss6"),get_node("ss7"),get_node("ss8"),get_node("ss9"),get_node("ss10"),get_node("ss11"),get_node("ss12"),get_node("ss13")]

onready var selectordict = {get_node("ss0"):selector.new(),get_node("ss1"):selector.new(),get_node("ss2"):selector.new(),get_node("ss3"):selector.new(),get_node("ss4"):selector.new(),get_node("ss5"):selector.new(),
get_node("ss6"):selector.new(),get_node("ss7"):selector.new(),get_node("ss8"):selector.new(),get_node("ss9"):selector.new(),get_node("ss10"):selector.new(),get_node("ss11"):selector.new(),get_node("ss12"):selector.new(),get_node("ss13"):selector.new()}



class selector:
	var visible = false
	var beaten = false

func _ready():
	if(global.comingbackfromlevel):
		BackFromLevel()
		var s = 0
		if(selectedroute == 1):
			s = 2
		elif(selectedroute == 2):
			s = 8
		selectors[positionpath + s - 1].get_node("AnimationPlayer").play("complete")
		selectors[positionpath + s - 1].visible = true
		selectors[positionpath + s - 1].beaten = true
		if(positionpath + s < selectors.size()):
			if(!selectors[positionpath + s].visible):
				selectors[positionpath + s].get_node("AnimationPlayer").play("fadein")
				selectors[positionpath + s].visible = true
		moving = true
		if(selectedroute == 0 and positionpath == 2):
			moving = false
		if(selectedroute == 1 and positionpath == 6):
			moving = false
		if(selectedroute == 2 and positionpath == 6):
			moving = false
#	set_fixed_process(true)
	set_process(true)

	pass

func _process(delta):
#	get_node("positionpath").text = str(positionpath)
	label.text = ""
	for i in selectors:
		label.text += " " + str(i.beaten)
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
	
	if(!selecting):
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
	var s = 0
	if(selectedroute == 1):
		s = 2
	elif(selectedroute == 2):
		s = 8
	selectors[positionpath + s - 1].get_node("AnimationPlayer").play("complete")
	
	if(positionpath == 0 and selectedroute == 0): #particular exception for the first level
#		get_tree().change_scene(fountainstages[0])
		pass
	positionpath += 1
	
	
	print(positionpath + s)
	if(positionpath > routes[selectedroute].size() - 1): #if you are at the end of your route
		print("got to the enddddddddd")
		if(selectedroute == 0 and goaround == 0):
			#ask player to pick route
			print("HELLLLLLLOW")
			selecting = true
			get_node("buttonmansion").show()
			get_node("buttonmountain").show()
			
		elif(selectedroute == 0 and goaround == 1):
			print("TIME TO GO PLACES")
			enafountain.remove_child(player)
			if(wentmountain):
				selectedroute = 2
				fountainmansion.add_child(player)
				fountainmountain.set_unit_offset(0)
			else:
				selectedroute = 1
				fountainmountain.add_child(player)
				fountainmansion.set_unit_offset(0)
			positionpath = 0
			player.set_pos(Vector2())
		elif(selectedroute == 1):
			selectedroute = 0
			goaround += 1
			positionpath = 0
			enafountain.set_unit_offset(0)
			fountainmountain.remove_child(player)
			enafountain.add_child(player)
			selectors[0].get_node("AnimationPlayer").play("rest")
			selectors[1].get_node("AnimationPlayer").play("rest")
			selectors[0].beaten = false
			selectors[1].beaten = false
			player.set_pos(Vector2())
			pass
			#end day do next path
			#if finished both paths load next map
		elif(selectedroute == 2):
			selectedroute = 0
			goaround += 1
			positionpath = 0
			enafountain.set_unit_offset(0)
			fountainmansion.remove_child(player)
			enafountain.add_child(player)
			player.set_pos(Vector2())
			selectors[0].get_node("AnimationPlayer").play("rest")
			selectors[1].get_node("AnimationPlayer").play("rest")
			selectors[0].beaten = false
			selectors[1].beaten = false
			fountainmansion.set_unit_offset(0)
	else:
		print(positionpath)
		if(selectedroute == 0):
			GoingToLevel()
			get_tree().change_scene(fountainstages[positionpath])
		if(selectedroute == 1):
			GoingToLevel()
			get_tree().change_scene(mountainstages[positionpath])
		if(selectedroute == 2):
			GoingToLevel()
			get_tree().change_scene((mansionstages[positionpath]))
		
#		if positionpath == 0:
#			pass
#			get_tree().change_scene("res://test/stages/1-1,2-1.tscn")
		#reveal next level selector
		#play cutscene then play level
	if(selectedroute == 1):
		s = 2
	elif(selectedroute == 2):
		s = 8
	if(!selectors[positionpath + s - 1].visible):
		selectors[positionpath + s - 1].get_node("AnimationPlayer").play("fadein")
	
	if(selecting):
		
		selectors[8].get_node("AnimationPlayer").play("fadein")
		selectors[8].visible = true
	

func _on_buttonmountain_button_up():
	selectedroute = 1
	positionpath = 0
	enafountain.remove_child(player)
	fountainmountain.add_child(player)
	player.set_pos(Vector2())
	selecting = false
	wentmountain = true
	get_node("buttonmansion").hide()
	get_node("buttonmountain").hide()
	pass # replace with function body


func _on_buttonmansion_button_up():
	selectedroute = 2
	positionpath = 0
	enafountain.remove_child(player)
	fountainmansion.add_child(player)
	fountainmountain.set_unit_offset(0)
	player.set_pos(Vector2())
	selecting = false
	get_node("buttonmansion").hide()
	get_node("buttonmountain").hide()
	pass # replace with function body

#going to level, send positions to global
func GoingToLevel():
	global.positionpath = positionpath
	global.positionroute = positionroute
	global.goaround = goaround
	global.selectedlevel = selectedlevel
	global.selectedroute = selectedroute
	global.mountainoffset = fountainmountain.get_unit_offset()
	global.mansionoffset = fountainmansion.get_unit_offset()
	global.fountainoffset = enafountain.get_unit_offset()
	global.wentmountain = wentmountain
	
	for i in range(selectors.size()):
		global.selectors[i].beaten = selectors[i].beaten
		global.selectors[i].visible = selectors[i].visible

#beat level, load previous positions
func BackFromLevel():
	positionpath = global.positionpath
	positionroute = global.positionroute
	goaround = global.goaround
	selectedlevel = global.selectedlevel
	selectedroute = global.selectedroute
	wentmountain = global.wentmountain
	print("Selected route")
	print(selectedroute)
	print("go around")
	print(str(goaround))
	if(selectedroute == 0):
		enafountain.set_unit_offset(global.fountainoffset)
	if(selectedroute == 1):
		enafountain.remove_child(player)
		fountainmountain.add_child(player)
		fountainmountain.set_unit_offset(global.mountainoffset)
	if(selectedroute == 2):
		enafountain.remove_child(player)
		fountainmansion.add_child(player)
		fountainmansion.set_unit_offset(global.mansionoffset)
	
	for i in range(selectors.size()):
		if(global.selectors[i].visible):
			selectors[i].visible = true
			selectors[i].get_node("AnimationPlayer").play("fadein")
		if(global.selectors[i].beaten):
			selectors[i].beaten = true
			selectors[i].get_node("AnimationPlayer").play("complete")