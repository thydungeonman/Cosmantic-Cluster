 extends Node2D


enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}
enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

var availablecolours = []

var rgodots = []
var listshots = false

const NONE = "res://test/scenes/orb.tscn"
const YELLOW = "res://test/scenes/yelloworb.tscn"
const BLUE = "res://test/scenes/blueorb.tscn"
const ORANGE = "res://test/scenes/orangeorb.tscn"
const PURPLE = "res://test/scenes/purpleorb.tscn"
const BLACK = "res://test/scenes/blackorb.tscn"
const GREEN = "res://test/scenes/greenorb.tscn"
const WHITE = "res://test/scenes/whiteorb.tscn"
const RED = "res://test/scenes/redorb.tscn"

var player = PLAYER.PLAYER2
onready var sfx = get_node("SamplePlayer")
onready var anim = get_node("LauncherAnimationPlayer")
onready var abilityanim = get_node("AbilityAnimationPlayer")
onready var nextorb = get_node("nextorb") # the sprite of the upcoming orb
var upcomingorb #this holds an enumeration for the upcoming orb ie the colour

var trajectory = Vector2(-1500,-1500) #vector that orb is to be fired at
var x = (PI)/2 #starting angle of launcher
var speed = PI/240
var minspeed = PI/1000
var maxspeed = PI/170
var standardmaxspeed = PI/170

var upperlimit = PI - 0.14
var lowerlimit = .14

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

var lasing = false
var laserisactive = false

onready var centercast = get_node("RayCastCenter/")
onready var leftcast = get_node("RayCastCenter/RayCastLeft")
onready var rightcast = get_node("RayCastCenter/RayCastRight")
onready var aim = get_node("Particles2D")
onready var container = get_node("container")
var next = null
var clicked = false
var clickedpos = Vector2(30,30) #global
var aiming = false

var foundtarget = false
var checkedlayer = false
var state =  5
#0 = find bottom orb that matches loaded orb
#1 = check aim
#2 = aim laucher at target
#3 = fire orb
#4 = swap orb
#5 = wait 
#6 = stop


var waittime = 1
var waitcounter = 0.0

var madeswap = false
var didstore = false

#onready var midwallpos = get_parent().get_node("middlewall").get_pos()
var bottomorbs = []
var target # orb to be aimed at

var playerflagpos = Vector2()
var playerflagcolour

var aiflagcolour

var scannerlist = []
var throwingaway = false # only used for board label


func _ready():
	set_fixed_process(true)
	next = preload("res://test/scenes/aimingreticule.tscn").instance()
	add_child(next)
	next.set_pos(Vector2(0,20))
	AimReticule()
	

func _fixed_process(delta):
	Click()
	if(throwingaway):
		get_parent().get_node("throwaway").show()
	else:
		get_parent().get_node("throwaway").hide()
#	print(get_parent().orbsonboardp2.size())
#	if(Input.is_action_pressed("click")):
#		if(!madeswap):
#			orb = Swap(orb)
#		madeswap = true
#	if(Input.is_action_pressed("rclick")):
#		if(!didstore):
#			Store(orb)
#		didstore = true
#	if(Input.is_action_pressed("ui_accept")):
#		state = 0
#		clickedpos = get_global_mouse_pos()
#		print("clicked pos = " + str(clickedpos - get_pos()))
#		aiming = true
#		#CheckAim(clickedpos)
#		print("mirrored  pos = " + str(clickedpos))
#		Store(orb)
	#print(aiming)
	LoadOrb(delta)
	#print(orb)
	
	if(state == 5):
		waitcounter += delta
		if waitcounter > waittime:
			state = 0
			waitcounter = 0.0
	#print(orb)
	if(state == 0 and loaded and canshoot):#(!checkedlayer and loaded):#(!aiming and loaded):
		if(CheckFlagShot()):
			foundtarget = true
			clickedpos = playerflagpos
			state = 2
		else:
			target = FullScan2()#CheckBottomLayer()
			if(target != null):
				print("target is "+ target.get_name() + " with colour "+ str(target.colour))
		
	if(state == 1):
		while(state == 1):
			state = 2
#			CheckAim(clickedpos)
	if(state == 2):
		aiming = AimAtPos(clickedpos - get_pos())
		if(aiming):
			state = 3
	if(state == 3):
		Fire()
		firing = true
		loaded = false
		shottimer = 0.0
		state = 0
		madeswap = false
	if(isfrozen):
		Defrost(delta)
	if(state == 4 and loaded):
		if(!madeswap):
			orb = Swap(orb)
			madeswap = true
		state = 0
	
	#LASER =========================================================>O
#	if(Input.is_action_pressed("laser")):
#		if(!lasing):
#			var las = preload("res://test/scenes/laser.tscn").instance()
#			get_parent().add_child(las)
#			las.set_pos(get_pos())
#			las.Charge(trajectory,x)
#			las.Fire()
#			lasing = true
#	else:
#		lasing = false
	
func Click():
	
	if(Input.is_action_pressed("click")):
		clicked = true
		return
		var shot = get_global_mouse_pos()
		var goodshot = false
		var lchecker = preload("res://test/scenes/laserchecker.tscn").instance()
		add_child(lchecker)
		while goodshot == false:
			var difference = shot - lchecker.get_global_pos()
			lchecker.set_rot(0)
			lchecker.look_at(lchecker.get_global_pos() + difference)
			var trajectory = shot - get_global_pos()
			var m = -abs(trajectory.y/trajectory.x)
			var x = 1900
			var s = 1900 - 1447
			
			if(shot.x < 1447):
				x = 1000
			var y = (m*s) + 980
#			print(str(y) + " = " + str(m) + " * " + str(s) + "+ 980" )
			var lchecker2 = preload("res://test/scenes/laserchecker.tscn").instance()
			add_child(lchecker2)
			lchecker2.set_global_pos(Vector2(x,y))
			lchecker2.look_at(Vector2(x + -difference.x,y + difference.y))
			goodshot = true
	

func LoadOrb(delta):
	if(upcomingorb == null):
#		randomize()
		if(availablecolours.size() > 0):
			var rand = randi() % availablecolours.size()
			if(availablecolours[rand] == COLOUR.YELLOW):
				upcomingorb = preload(YELLOW).instance()
			elif(availablecolours[rand] == COLOUR.BLUE):
				upcomingorb = preload(BLUE).instance()
			elif(availablecolours[rand] == COLOUR.RED):
				upcomingorb = preload(RED).instance()
			elif(availablecolours[rand] == COLOUR.ORANGE):
				upcomingorb = preload(ORANGE).instance()
			elif(availablecolours[rand] == COLOUR.PURPLE):
				upcomingorb = preload(PURPLE).instance()
			elif(availablecolours[rand] == COLOUR.GREEN):
				upcomingorb = preload(GREEN).instance()
			elif(availablecolours[rand] == COLOUR.BLACK):
				upcomingorb = preload(BLACK).instance()
			elif(availablecolours[rand] == COLOUR.WHITE):
				upcomingorb = preload(WHITE).instance()
		else:
			var rand = randi() % 8
			if(rand == 0):
				upcomingorb = preload(YELLOW).instance()
			elif(rand == 1):
				upcomingorb = preload(BLUE).instance()
			elif(rand == 2):
				upcomingorb = preload(RED).instance()
			elif(rand == 3):
				upcomingorb = preload(ORANGE).instance()
			elif(rand == 4):
				upcomingorb = preload(PURPLE).instance()
			elif(rand == 5):
				upcomingorb = preload(GREEN).instance()
			elif(rand == 6):
				upcomingorb = preload(BLACK).instance()
			elif(rand == 7):
				upcomingorb = preload(WHITE).instance()
		nextorb.set_texture(upcomingorb.get_node("Sprite").get_texture())
	
	shottimer += delta
	if(shottimer > 1):
		if(loaded == false):
			orb = upcomingorb #make the switch
			upcomingorb = null
			nextorb.set_texture(null)
			
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())#set the orb to launcher position
			
			if(player == PLAYER.PLAYER1):
				orb.player = orb.PLAYER.PLAYER1
				orb.onboard = orb.PLAYER.PLAYER1
			if(player == PLAYER.PLAYER2):
				orb.player = orb.PLAYER.PLAYER2
				orb.onboard = orb.PLAYER.PLAYER2
			loaded = true
			orb.inlauncher = true
			print("loaded new orb")

func AimAtPos(position):#position must be local to the launcher
	#move reticule closer to position
	#if not close enough after one increment, return false, else return true
	var target = -Vector2(-1500,0).angle_to(position)
	if(target < x):
		if(abs(target - x) < .03):
			speed = minspeed
		else:
			speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		
		AdjustReticule()
	elif(target > x):
		if(abs(target - x) < .03):
			speed = minspeed
		else:
			speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		
		AdjustReticule()
	#print(str(target) + " " + str(x))
	if(abs(target - x) <.01): #is the trajectory close enough to the target
		state = 3
		
func AimAtBouncePos(position):
	#use a two step process
	#first adjust for the y. The shot must always be at a lower y than the orb thats being aimed at
	# then after that adjust for the x. The correct angle must be within the remaining degrees
	
	#roughly the top 45 percent of the remaining degrees will cover orbs of the same y value
	
	#first aim 8.5 degrees left of the orb acting as if the orb was at x = 87
	#then multiply the current angle by cos(x/500) where x is the x value of the orb you want to hit
	
#	var target = -Vector2(-1500,0).angle_to(Vector2(position.x-30,position.y+60))
#	if(target < x):
#		speed += PI/1500
#		speed = clamp(speed,minspeed,maxspeed)
#		x -= speed
#		x = clamp(x,lowerlimit,upperlimit)  
#		AdjustReticule()
#	elif(target > x): 
#		speed += PI/1500
#		speed = clamp(speed,minspeed,maxspeed)
#		x += speed
#		x = clamp(x,lowerlimit,upperlimit) 
#		AdjustReticule()
#	print(str(target) + " " + str(x))
#	return (abs(target - x) <.01) #is the trajectory close enough to the target
	
	#screw that, new plan
	#to figure the angle needed for a bounce shot, simply aim at the orb in a reflected position
	var difference = 960 - position.x
	var target = -Vector2(-1500,0).angle_to(Vector2(position.x,position.y))
	print("pos is " + str(position))
	pass

#only works for the right side player ie p2 or the AI
#position is the clicked position or the orb position 
#side = 0 for a left side bounce shot, 1 for the right side
func Mirror(position,side = 0):
	if(side != 0 and side != 1):
		side = 0
	if(side == 0):
		var difference = position.x - 960 - 67 #centerwall x pos = 960 then minus roughly half an orb plus half the middle wall
		var mirrorx = 960 - difference
		var mirrorpos = Vector2(mirrorx,position.y)
		return mirrorpos - get_pos()
	elif(side == 1):
		var difference = 1912 - position.x
		var mirrorx = 1912 + difference
		var mirrorpos = Vector2(mirrorx,position.y)
		return mirrorpos - get_pos()
	
	pass
	
func AimAtAngle(angle):
	
	if(angle < x):
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		AdjustReticule()
	elif(angle > x):
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		AdjustReticule()
	#print(str(angle) + " " + str(x))
	return (abs(angle - x) <.01) #is the trajectory close enough to the target

#func GetAimControlsP1(delta):
#	if(Input.is_action_pressed("p1_aim_left")):
#		#print(speed)
#		speed += PI/1500
#		speed = clamp(speed,minspeed,maxspeed)
#		x -= speed
#		x = clamp(x,lowerlimit,upperlimit)     
#		aim.set_param(0,270 - rad2deg(x))
#		AdjustReticule()
#		#print(str(x) + " " + str(tan(x)))
#		sfx.play("mrown1__tick launcher aiming left or right")
#	elif(Input.is_action_pressed("p1_aim_right")):
#		#print(speed)
#		speed += PI/300
#		speed = clamp(speed,minspeed,maxspeed)
#		x += speed
#		x = clamp(x,lowerlimit,upperlimit)
#		aim.set_param(0,270 - rad2deg(x))
#		AdjustReticule()
#		#print(str(x) + " " + str(tan(x)))
#		sfx.play("mrown1__tick launcher aiming left or right")
#	else:
#		speed = minspeed
#
#func GetAimControlsP2(delta):
#	if(Input.is_action_pressed("p2_aim_left")):
#		#print(speed)
#		speed += PI/1500
#		speed = clamp(speed,minspeed,maxspeed)
#		x -= speed
#		x = clamp(x,lowerlimit,upperlimit)
#		aim.set_param(0,270 - rad2deg(x))
#		AdjustReticule()
#		#print(str(x) + " " + str(tan(x)))
#		sfx.play("mrown1__tick launcher aiming left or right")
#	elif(Input.is_action_pressed("p2_aim_right")):
#		#print(speed)
#		speed += PI/300
#		speed = clamp(speed,minspeed,maxspeed)
#		x += speed
#		x = clamp(x,lowerlimit,upperlimit)
#		aim.set_param(0,270 - rad2deg(x))
#		AdjustReticule()
#		#print(str(x) + " " + str(tan(x)))
#		sfx.play("mrown1__tick launcher aiming left or right")
#	else:
#		speed = minspeed
#
#func GetFireControlsP1(delta):
#	if(Input.is_action_pressed("p1_fire") and loaded == true): #if the key is pressed and the launcher is loaded
#		if(!firing and canshoot):
#			Fire()
#			firing = true
#			loaded = false
#			shottimer = 0.0
#			#get_parent().orbsonboard.push_front(orb)
#			#get_parent().orbsonboardp1.push_front(orb)
#			Disable()
#	else:
#		firing = false
#	if(Input.is_action_pressed("p1_store") and !container.IsFull()):
#		if(storing == false):
#			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
#			get_parent().remove_child(orb)
#			print(str(get_parent().orbsonboard.size()))
#			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
#			print(str(get_parent().orbsonboard.size()))
#			container.TakeOrb(orb)
#			loaded = false
#			storing = true
#			sfx.play("bump - orb saved for later")
#	else:
#		storing = false
#	
#	if(Input.is_action_pressed("p1_swap") and !container.IsEmpty() and !swapped):
#		if(swapping == false):
#			print(str(orb))
#			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
#			get_parent().remove_child(orb)
#			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
#			orb = container.Swap(orb)
#			get_parent().add_child(orb)
#			orb.set_pos(get_global_pos())
#			#get_parent().orbsonboard.push_front(orb)
#			swapping = true
#			swapped = true
#			sfx.play("hurt-c-02 - orb switch")
#			print(str(orb))
#	else:
#		swapping = false
#
#func GetFireControlsP2(delta):
#	if(Input.is_action_pressed("p2_fire") and loaded == true): #if the key is pressed and the launcher is loaded
#		if(!firing and canshoot):
#			Fire()
#			firing = true
#			loaded = false
#			shottimer = 0.0
#			#get_parent().orbsonboard.push_front(orb)
#			#get_parent().orbsonboardp2.push_front(orb)
#			Disable()
#			
#	else:
#		firing = false
#	if(Input.is_action_pressed("p2_store") and !container.IsFull()):
#		if(storing == false):
#			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
#			get_parent().remove_child(orb)
#			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
#			container.TakeOrb(orb)
#			loaded = false
#			storing = true
#			sfx.play("bump - orb saved for later")
#	else:
#		storing = false
#	
#	if(Input.is_action_pressed("p2_swap") and !container.IsEmpty() and !swapped):
#		if(swapping == false):
#			print(str(orb))
#			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
#			get_parent().remove_child(orb)
#			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
#			orb = container.Swap(orb)
#			get_parent().add_child(orb)
#			orb.set_pos(get_global_pos())
#			#get_parent().orbsonboard.push_front(orb)
#			swapping = true
#			swapped = true
#			print(str(orb))
#			sfx.play("hurt-c-02 - orb switch")
#	else:
#		swapping = false


func Fire():
	# if yellow ablility = true
	# spawn lightning area and child to orb
	# when orb stops check bool in orb and then activate lightning
	#print(str(orb))
	throwingaway = false
	if(laserisactive):
		Disable()
		var laser = preload("res://test/scenes/laser.tscn").instance()
		var c = orb.colour
		orb.queue_free()
		get_parent().add_child(laser)
		laser.set_pos(get_pos())
		laser.colour = c
		laser.player = player
		laser.Charge(trajectory,x)
		laser.Fire()
		laserisactive = false
		sfx.play("laser-shot-silenced - orange ability launched")
		abilityanim.play("rest")
	else:
		Disable()
		orb.trajectory.x = trajectory.x * cos(x)
		orb.trajectory.y = trajectory.y * sin(x)
		orb.get_node("sparkles").set_rot(x- (PI/2))
		orb.ismoving = true
		orb.inlauncher = false
		orb.Sparkle()
		if(ischarged):
			orb.Charge()
			ischarged = false
			sfx.play("electric-zap-001 - Yellow ability launched")
			abilityanim.play("rest")
		swapped = false
		sfx.play("jump-c-05 - orb launched")
	print("fired " + orb.get_name() + " with colour " + str(orb.colour))

func Freeze(duration,tier):
	maxspeed = ((4.0-tier)/4.0) * standardmaxspeed
	print("max speeds")
	print(maxspeed)
	print(standardmaxspeed)
	isfrozen = true
	frozentime = duration
	anim.play("freeze")

func Defrost(delta):
	frozentimer += delta
	if(frozentimer >= frozentime):
		speed = PI/170
		isfrozen = false
		frozentimer = 0.00
		frozentime = 1.0
		sfx.play("ice-cracking - laucher unfreezing")
		anim.play("crack")

func Charge(): #yellow abilty
	ischarged = true
	abilityanim.play("lightning")

func Enable():
	canshoot = true
func Disable():
	canshoot = false
func ActivateLaser():
	laserisactive = true
	abilityanim.play("laser")

func AimReticule():
	var reticuletrajectory = Vector2((trajectory.x * cos(x))/100,(trajectory.y * sin(x))/100)
	next.ExtendLine(reticuletrajectory)
	
func AdjustReticule():
	var reticuletrajectory = Vector2((trajectory.x * cos(x))/100,(trajectory.y * sin(x))/100)
	next.ModifyLine(reticuletrajectory)
	
func Reset():
	orb.queue_free()
	upcomingorb = null
	nextorb.set_texture(null)
	shottimer = 0
	loaded = false
	laserisactive = false
	ischarged = false;
	abilityanim.play("rest")
	anim.play("rest")
func DamageAnim():
	abilityanim.play("damage")
func HealAnim():
	abilityanim.play("heal")

#calculate trajectory to hit opponents flag orb 
#determine which orbs are in the way and what colours they are
#raycast will have to shift left and right to simulate the size of an orb
#dig through and destroy opponents flag orb

#throw away an unneeded orb
func ThrowAway():
	var pos = get_parent().FindGap()
	if pos != null:
		clickedpos = pos
		aiming = false
#		print("SUPERIOR THROWAWAY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return
	
	var isroom = false
	while(!isroom):
#		randomize()
		var randspot = int(randi() % 800) + 1000
		clickedpos = Vector2(randspot,615)
		var localpos = clickedpos - get_pos()
		var hyp = sqrt(localpos.x * localpos.x + localpos.y * localpos.y) * -1
		var hypvector = Vector2(0,hyp)
		centercast.set_cast_to(hypvector)
		leftcast.set_cast_to(hypvector)
		rightcast.set_cast_to(hypvector)
		centercast.set_rot(centercast.get_pos().angle_to_point(clickedpos - get_pos()))
		centercast.force_raycast_update()
		rightcast.force_raycast_update()
		leftcast.force_raycast_update()
		if(!leftcast.is_colliding() and !centercast.is_colliding() and !rightcast.is_colliding()):
			isroom = true
		else:
			isroom = false
		if centercast.is_colliding() and centercast.get_collider().is_in_group("flag") and aiflagcolour == orb.colour:
			isroom = false
			print("avoiding disaster **********************************")
	
	print("THROWAWAY")
	print(clickedpos)
	aiming = false


func ThrowAway2(straightshottargets,bounceshottargets,warpshottargets,emptyshots):
	#Analyse the orbs that can be hit with a straight shot and decide where to 
	#throw away a unneeded orb
	#don't aim at: orbs that are in a group of 2,
	#own flag orb
	#enemy flag orb
	#orbs that are very close to launcher
	throwingaway = true
	#don't aim at the enemy flag orb
	get_parent().get_node("throwaway").set_text("THROWING AWAY")
	var fulltargetdict = straightshottargets
	for key in warpshottargets.keys():
		fulltargetdict[key] = warpshottargets[key]
	var potentialtargets = []
	var potential = false
	if(emptyshots.size() > 0):
		clickedpos = emptyshots[0]
		print("TAKING AN EMPTY SHOT")
		return
	
	for target in straightshottargets.keys():
		var group = []
		group = target.Search(1,target.colour,group)
		if(group < 0):
			continue
		if(target.isflag):
			continue
		if(get_pos().distance_to(target.get_pos()) < 130):
			print("TOO CLOSE")
			continue
		potentialtargets.push_back(target)
	for target in warpshottargets.keys():
		var group = []
		group = target.Search(1,target.colour,group)
		if(group < 0):
			continue
		if(target.isflag):
			continue
		if(get_pos().distance_to(target.get_pos()) < 160):
			print("TOO CLOSE")
			continue
		potentialtargets.push_back(target)
	if(potentialtargets.size() > 0):
		var shot = randi() % potentialtargets.size()
		clickedpos = fulltargetdict[potentialtargets[shot]]
		state = 2
		print(potentialtargets[0].get_name())
	else:
		ThrowAway()
	


#swap  orb with container
func Swap(oldorb):
	print("swapped: " + str(swapped))
#	print(str(oldorb))
#	print(GetStoredOrbs())
	oldorb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
	get_parent().remove_child(oldorb)
	#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
	var neworb = container.Swap(oldorb)
	get_parent().add_child(neworb)
	neworb.set_pos(get_global_pos())
	neworb.inlauncher = true
	#get_parent().orbsonboard.push_front(orb)
	swapping = true
	swapped = true
	sfx.play("hurt-c-02 - orb switch")
	print("new orb is " + str(neworb.get_name()) + " with colour " + str(neworb.colour))
	print("MADE A SWAP")
#	print(GetStoredOrbs())
	return neworb

#store orb in container
func Store(orb):
	if(!container.IsFull()):
		orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it doesn't stay in the same spot and collide with new orbs
		get_parent().remove_child(orb)
		container.TakeOrb(orb)
		loaded = false
		storing = true
		sfx.play("bump - orb saved for later")
		
#get list of stored orbs from the container
func GetStoredOrbs():
	return container.GetOrbs()

#calculate tragecotry to hit opponents flag orb
func FindPath():
	pass

#determine which orbs are along the flag orb trajectory
#making sure to clear enough room for a whole orb to pass through
func FindPathOrbs():
	pass

#throwaway and swap until desired orb is loaded
func SwapUntil():
	pass

#run through the bottom layer of orbs
#will be used too know where to throwaway orbs
#need to figure out how to blacklist orbs and unblackist them when an orb is fired
#run through checking the orbs and if a bad one is returned just blacklist it and run through the rest
func CheckBottomLayer():
	if(laserisactive):
		var t = get_parent().FindPeninsula(orb.colour)
		if(t != null):
			print("FOUND TARGET ORB !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
			print(t)
			clickedpos = t.get_pos()
			foundtarget = true
			state = 2
			return t
		print("DIDNT FIND TARGET ORB  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	var borbs = []
	print("CHECKING ORBS")
	bottomorbs = get_parent().FindBottomLayer()
	for borb in bottomorbs:
		#print(borb)
		if(borb.colour == orb.colour):
			borbs.push_back(borb)
			
	if(borbs.size() == 1):
		print("ONE BORB")
		clickedpos = borbs[0].get_pos()
		foundtarget = true
		state = 1
		return borbs[0]
	elif(borbs.size() > 1):
		print("MULTIPLE BORBS")
		for borb in borbs:
			var ar = []
			print(borb.Search(1,borb.colour,ar).size())
			if(borb.Search(1,borb.colour,ar).size() >= 1):
				print("FOUND GOOD MATCH")
				for i in ar:
					print(i)
				clickedpos = borb.get_pos()
				foundtarget = true
				state = 1
				return borb
		clickedpos = borbs[0].get_pos()
		foundtarget = true
		state = 1
		return borbs[0]
	if(container.IsFull()):
		if(!madeswap):
			orb = Swap(orb)
			madeswap = true
			state = 0
		else:
			state = 2
			ThrowAway()
	else:
		Store(orb)
		state = 0

#make sure to clear enough room for a whole orb to hit target
func CheckAim(position):
	var localpos = position - get_pos()
	var hyp = sqrt(localpos.x * localpos.x + localpos.y * localpos.y) * -1
	var hypvector = Vector2(0,hyp)
	centercast.set_cast_to(hypvector)
	leftcast.set_cast_to(hypvector)
	rightcast.set_cast_to(hypvector)
	centercast.set_rot(centercast.get_pos().angle_to_point(position - get_pos()))
	centercast.force_raycast_update()
	rightcast.force_raycast_update()
	leftcast.force_raycast_update()
	
	if(localpos.x <= 0): # left side shot
		if(!centercast.is_colliding() and !rightcast.is_colliding()):
			Mirror(target.get_global_pos(),0)
			print("BOUNCE SHOT")
				#ThrowAway()
				#aiming = false
			state = 2
			return
		elif(centercast.get_collider() != target or rightcast.get_collider() != target):
			clickedpos.x -=2
			clickedpos.y += 2
#				print("ADJUST LEFT")
			return
		else: #both are equal to target
			aiming = false
			state = 2
			return
	elif(localpos.x > 0): # right side shot
		if(!centercast.is_colliding() and !leftcast.is_colliding()):
			Mirror(target.get_global_pos(),1)
			print("BOUNCE SHOT")
			aiming = false
			state = 2
			return
		elif(centercast.get_collider() != target or leftcast.get_collider() != target):
			clickedpos.x +=2
			clickedpos.y += 2
#				print("ADJUST RIGHT")
			return
		else:
			print("COLLIDERS")
			print(centercast.get_collider())
			print(leftcast.get_collider())
			aiming = false
			state = 2
		return
	print("Something is weird")
	# if can not raycast at target, aimcheck on bounce shot positions

func CheckFlagShot():
	var localpos = playerflagpos - get_pos()
	var hyp = sqrt(localpos.x * localpos.x + localpos.y * localpos.y) * -1
	var hypvector = Vector2(0,hyp)
	centercast.set_cast_to(hypvector)
	leftcast.set_cast_to(hypvector)
	rightcast.set_cast_to(hypvector)
	centercast.set_rot(centercast.get_pos().angle_to_point(playerflagpos - get_pos()))
	centercast.force_raycast_update()
	rightcast.force_raycast_update()
	leftcast.force_raycast_update()
	if((centercast.is_colliding() == false and leftcast.is_colliding() == false and rightcast.is_colliding() == false) and orb.colour == playerflagcolour):
		print("CAN MAKE GOOD FLAG SHOT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print(orb.colour)
		print(playerflagcolour)
		return true
	#if can hit player flag orb and have matching orb always take the shot
	#if cannot hit player flag orb but can hit an orb that touches the player flag orb and matches colour, take the shot



func laserScan():
	var shot
	var t = get_parent().FindPeninsula(orb.colour)
	if(t == null):
		t = Vector2(1500,300)
	else:
		shot = t.get_pos()
	var goodshot = false
	var lchecker = preload("res://test/scenes/laserchecker.tscn").instance()
	add_child(lchecker)
	while goodshot == false:
		var difference = shot - lchecker.get_global_pos()
		lchecker.set_rot(0)
		lchecker.look_at(lchecker.get_global_pos() + difference)
		var trajectory = shot - get_global_pos()
		var m = -abs(trajectory.y/trajectory.x)
		var x = 1900
		var s = 1900 - 1447
		if(shot.x < 1447):
			x = 1000
		var y = (m*s) + 980
		print(str(y) + " = " + str(m) + " * " + str(s) + "+ 980" )
		var lchecker2 = preload("res://test/scenes/laserchecker.tscn").instance()
		add_child(lchecker2)
		lchecker2.set_global_pos(Vector2(x,y))
		lchecker2.look_at(Vector2(x + -difference.x,y + difference.y))
		var goodloop = true
		for body in lchecker.get_overlapping_bodies() + lchecker2.get_overlapping_bodies():
			if(body.is_in_group("orb")):
				if(body.isflag and body.player == PLAYER.PLAYER2):
					shot.x += 5
					goodloop = false
					break
		lchecker.queue_free()
		lchecker2.queue_free()
		if(!goodloop):
			continue
		break
	goodshot = true
	clickedpos = shot
	state = 2


func FullScan2():
	#brute force scan of all orbs that can be hit from the ailauncher
	#start aiming at the top left corner of the aiboard and move one or more pixels at a time until youre at the right side
	#or rotate the currentpoint vector
	
	#new plan make a dict of bouncepoints and remainders
	#the in a new loop give the scanner a collision exception with the wall
	#and try to move it the remainder of the distance
	#hopefully it will collide
	
	if(ischarged):
		print("CHARGED")
	else:
		print("NOT CHARGED")
	
	for r in rgodots:
		r.queue_free()
	rgodots.clear()
	
	
	for i in scannerlist:
		i.queue_free()
	scannerlist.clear()
	
	var scanner
	var bouncescanner
	var currentpoint = Vector2(-1200,-50)
	var i = 0
	var list = [] #orbs that can be hit with regular shots
	var bouncelist = [] #orbs that can be hit with bounce shots
	var pointdict = {} #points that aim at orbs
	var bouncedict = {} #points along the wall and reverse trajectory
	var bouncepointdict = {} #points along the wall and the corresponding orb
	var emptyshots = [] #currentpoints that don't hit an orb, meaning a clear shot at the warp
	var warpbouncedict = {} #currentpoints and bounced warp positions
	var warpbouncepointdict = {} #currentpoints and orbs
	
	var lastorb = null
	var currentorb = null
	var borbs = []
	
	
	
	if(laserisactive):
		laserScan()
		return
	
	scanner = preload("res://test/scenes/scanner.tscn").instance()
	add_child(scanner)
	scanner.add_collision_exception_with(orb)
	
#	
	bouncescanner = preload("res://test/scenes/scanner.tscn").instance()
	add_child(bouncescanner)
	bouncescanner.add_collision_exception_with(orb)
	bouncescanner.add_collision_exception_with(scanner)
	scanner.add_collision_exception_with(bouncescanner)
	var hits = []
	var lastshotorb 
	while (i != 120):
		var remainder = scanner.move(currentpoint)
		if(scanner.is_colliding()):
			if(scanner.get_collider().is_in_group("orb")):
				
				currentorb = scanner.get_collider()
				if currentorb != lastorb:
					var average = Vector2()
					if(lastorb != null):
						for hit in hits:
							average += hit
						pointdict[lastorb] = average / hits.size()
						
					hits = [scanner.get_global_pos()]
					pointdict[currentorb] = scanner.get_global_pos()
					lastorb = currentorb
				else:
					hits.push_back(scanner.get_global_pos())
				list.push_back(scanner.get_collider())
#				scanner.get_collider().get_node("Sprite").set_opacity(0)
				var spot = scanner.get_global_pos()
			
			if(scanner.get_collider().is_in_group("wall")):
				bouncedict[scanner.get_global_pos()] = remainder
		else:
			emptyshots.push_back(currentpoint)
		scanner.set_pos(Vector2())
		currentpoint = currentpoint.rotated(-.025)
		i += 1
	print("printing list shots")
	for key in pointdict.keys():
#		var g = preload("res://test/scenes/rgodot.tscn").instance()
#		add_child(g)
#		rgodots.push_back(g)
#		g.set_global_pos(pointdict[key])
		if(listshots):
			print(key.get_name())
	print("done printing list shots")
	
	scanner.queue_free()
	bouncescanner.add_collision_exception_with(get_parent().get_node("wall"))
	bouncescanner.add_collision_exception_with(get_parent().get_node("wall 2"))
	bouncescanner.add_collision_exception_with(get_parent().get_node("middlewall"))
	for key in bouncedict.keys():
		bouncescanner.set_global_pos(key)
		bouncescanner.move(Vector2(-bouncedict[key].x,bouncedict[key].y))
		if(bouncescanner.is_colliding()):
			if(bouncescanner.get_collider().is_in_group("orb")):
				bouncepointdict[bouncescanner.get_collider()] = key
#				print(bouncescanner.get_collider().get_name())
				bouncelist.push_back(bouncescanner.get_collider())
		else:
			#grab bounce point and current point
			#figure out what its x will be when it warps
			#if its x is outside of the board then reject it
			
			#key: global position of where the scanner is when it hits the wall
			#bouncedict[key] just a trajectory  global trajectory since y is negative going up
			
			#tinker with the values or just use the trajectory and wall position
			#to figure out what the x will be when the y is 100 or so
			
			#link trajectory/currentpoint  with warp exit point
			#move scanner at trajectory.x -trajectory.y
			#link bounce point with collider
			
			var m = (bouncedict[key].y/bouncedict[key].x)
			var b = key.y
			var localx = (-100 - (b)) / -m
			var realx #1868
			if(m > 0):
				realx = localx + 1025
				if(realx > 1030): #1025
					pass
					warpbouncedict[bouncedict[key]] = [Vector2(1920 - realx,0),key]
			else:
				realx = localx + 1868
				if(realx < 1860): #1868
					pass
					warpbouncedict[bouncedict[key]] = [Vector2(1920 - realx,0),key]
		bouncescanner.set_pos(Vector2())
		
	#DO THE SAME WITH EMPTY SHOTS USING THE CHECKER TO SEE WHERE THEY WILL LAND ON THE OTHER BOARD
	#orbs hit the warp at y = -100 or -1080 locally
	#x = y / (currentpoint.y / currentpoint.x)
	
	var warppointdict = {}
	for shot in emptyshots:
		var localx = -(1080 / (shot.y/shot.x))
		var realx = localx + get_pos().x
		scanner.set_global_pos(Vector2(0 + (1920 - realx),0))
		scanner.move(-shot)
		if(scanner.is_colliding() and scanner.get_collider().is_in_group("orb")):
			warppointdict[scanner.get_collider()] = shot + get_pos()

	for key in warpbouncedict.keys():
		scanner.set_global_pos(warpbouncedict[key][0])
		scanner.move(Vector2(key.x,-key.y))
		if(scanner.is_colliding()):
			if(scanner.get_collider().is_in_group("orb")):
				warpbouncepointdict[scanner.get_collider()] = warpbouncedict[key][1]

	
#	for key in warpbouncepointdict.keys():
#		print(key.get_name())
	
	
	
	var uniquebouncelist = []
	for i in bouncelist:
		if(!uniquebouncelist.has(i)):
			uniquebouncelist.push_back(i)
	bouncescanner.queue_free()
	
	var uniquelist = []
	for i in list:
		if (!uniquelist.has(i)):
			uniquelist.push_back(i)
	scanner.queue_free()
	
	var fulltargetlist = pointdict.keys() + warppointdict.keys()
	for key in bouncepointdict.keys():
		if(!fulltargetlist.has(key)):
			fulltargetlist.push_back(key)
	for key in warpbouncepointdict.keys():
		if(!fulltargetlist.has(key)):
			fulltargetlist.push_back(key)
#	
	
	#target finding starts
	
	#thought process
	#make a search for flag orb function
	
	while state == 0:
		borbs.clear()
		
		for borb in fulltargetlist:
			if(borb.colour == orb.colour):
				borbs.push_back(borb)
		
		if(ischarged): 
			var target = ChargeScan(borbs)
			if(target != null):
				if(pointdict.keys().has(target)):
					clickedpos = pointdict[target]
				elif(bouncepointdict.keys().has(target)):
					clickedpos = bouncepointdict[target]
				elif(warppointdict.keys().has(target)):
					clickedpos = warppointdict[target]
				else:
					clickedpos = warpbouncepointdict[target]
				foundtarget = true
				state = 1
				return target 
		
		if(borbs.size() == 1):
			print("ONE BORB")
			var targets = []
			#bail if matching this orb would match with flag orb
			var bail1 = false
			if(borbs[0].colour == aiflagcolour):
				
				if borbs[0].SearchFor(7,borbs[0].colour,get_parent().p2flag,true) or borbs[0] == get_parent().p2flag:
					bail1 = true 
					fulltargetlist.remove(fulltargetlist.find(borbs[0]))
					print("removed " + str(borbs[0].get_name()) + " would have matched flag")
					print("SUPREME ULTRA BAILINGLLLDKFJSDKFJSLDF")
					continue
			
			#bail if matching this orb would drop the flag orb
			if(!bail1):
				var nearest = []
				nearest = borbs[0].Search(2,borbs[0].colour,nearest)
				for corb in nearest:
					corb.isexcluded = true
				var a = []
				if(get_parent().p2flag.LookForTop(a) == false):
					bail1 = true
					fulltargetlist.remove(fulltargetlist.find(borbs[0]))
					print("removed " + str(borbs[0].get_name()) + " would have dropped flag")
				for corb in nearest:
					corb.isexcluded = false
			
			
			if(!bail1):
				if(pointdict.keys().has(borbs[0])):
					clickedpos = pointdict[borbs[0]]
				elif(bouncepointdict.keys().has(borbs[0])):
					clickedpos = bouncepointdict[borbs[0]]
				elif(warppointdict.keys().has(borbs[0])):
					clickedpos = warppointdict[borbs[0]]
				else:
					clickedpos = warpbouncepointdict[borbs[0]]
				foundtarget = true
				state = 1
				return borbs[0]
			print("BAILING @@@@@@@@@@@@@@@@@@@@@@@@@@@@")
			
		elif(borbs.size() > 1):
			print("MULTIPLE BORBS ARE")
			for borb in borbs:
				print("BORB")
				print(borb.get_name() + "with colour " + str(borb.colour))
				var ar = []
	#			print(borb.Search(1,borb.colour,ar).size())
#				var targets = borb.Search(7,borb.colour,ar,true)
				var bail2 = false
#				for i in targets:
#					if i.isflag and orb.colour == aiflagcolour:
#						bail2 = true
#						print("BAILING !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
#						fulltargetlist.remove(fulltargetlist.find(i))
#						break
				if(borb.colour == get_parent().p2flag.colour):
					if(borb.SearchFor(7,borb.colour,get_parent().p2flag,true)):
						fulltargetlist.remove(fulltargetlist.find(borb))
						print("removed " + str(borb.get_name()) + " would have matched flag")
						bail2 = true
				if(!bail2):
					print("bail 2 is false")
					var nearest = []
					nearest = borb.Search(2,borb.colour,nearest)
					for corb in nearest:
						corb.isexcluded = true
					var a = []
					if(get_parent().p2flag.LookForTop(a) == false):
						bail2 = true
						fulltargetlist.remove(fulltargetlist.find(borb))
						print("removed " + str(borb.get_name()) + " would have dropped flag")
					for corb in nearest:
						corb.isexcluded = false
				
				if bail2:
					print("bail2 is true")
					continue
				if(borb.Search(1,borb.colour,ar).size() >= 1):
					print("FOUND GOOD MATCH")
	#				for i in ar:
	#					pass
	#					print(i)
					if(pointdict.keys().has(borb)):
						clickedpos = pointdict[borb]
					elif(bouncepointdict.keys().has(borb)):
						clickedpos = bouncepointdict[borb]
					elif(warppointdict.keys().has(borb)):
						clickedpos = warppointdict[borb]
					else:
						clickedpos = warpbouncepointdict[borb]
					foundtarget = true
					state = 1
					return borb
				else:
					print("bad search")
			print("backup checking")
			for borb in borbs:
				if fulltargetlist.find(borb) != -1:
					print("found single orb")
					if(pointdict.keys().has(borb)):
						clickedpos = pointdict[borb]
					elif(bouncepointdict.keys().has(borb)):
						clickedpos = bouncepointdict[borb]
					elif(warppointdict.keys().has(borb)):
						clickedpos = warppointdict[borb]
					else:
						clickedpos = warpbouncepointdict[borb]
					foundtarget = true
					state = 1
					return borb
		
	#		foundtarget = true
	#		state = 1
	#		return borbs[0] #change this
		if(container.IsFull()):
			if(!madeswap):
	#			state = 4
				orb = Swap(orb)
				madeswap = true
				state = 0
			else:
				state = 2
				print("TROWING AWAY AN ORBBBBBB")
				print("throwing away an orb")
				print("orb is "+ orb.get_name())
				ThrowAway2(pointdict,bouncepointdict,warppointdict,emptyshots)
		else:
			print("storing " + orb.get_name())
			Store(orb)
			state = 0
			return #to exit the loop
	print("exited function somehow")






func ChargeScan(targets): #borbs
	#should be used after gotten borbs
	#check to see if using a yellow ability on the targeted orb will
	#shock the flag orb or drop the flag orb
	#not only avoid bad shots but pick the best shot
	#edge case scenario is that the orb that is shot bridges two groups
	#it would be difficult to check for that
	
	#have dict of target borb and how many things it will shock with yellow ability
	#for each borb:
	#first check if a match could even be made
	#if it can then get the match group
	#search for surrounding orbs of same colour and grey orbs
	#is the flag orb the same colour?
	#if it is and the flag orb is in that then bail
	#is flag at the top already?
	#if not then can the flag get to the top with those orbs excluded?
	#if not then bail
	#if not bailed at this point add to dict [target] = shocks
	#return target with most shocks or null if there are none
	
	var testedorbs = [] # list of orbs that have been checked so they are not checked more than once
	var goodorbs = {} # target = how many grey and same coloured orbs it shocks / maybe drops eventually
	var masterlist = []
	
	for target in targets:
		print("STARTING CHARGE TARGET " + target.get_name())
		# check match, more than 2 in group to be fired at
		var list = []
		list = target.Search(7,target.colour,list,true)
		masterlist.append(list)
		if(list.size() > 1):
			var next = false
			for i in list:
				if i == get_parent().p2flag:
					print("has flag in match group")
					next = true
					break
			if next:
				print("going to next target")
				continue # next target
			for i in list:
				i.isexcluded = true
			var mastershocks = []
			var bail = false
			for i in list:
				var shocks = []
				bail = false
				shocks = i.ChargeSearch(2,i.colour,shocks)
				if shocks.size() > 0:
					for s in shocks:
						if(s == get_parent().p2flag):
							bail = true
							print("will shock flag")
							break #stop looking at shocks
							
						if !mastershocks.has(s):
							mastershocks.append(s)
					if bail:
						for l in list:
							l.isexcluded = false
						print("breaking from loop")
						break #leave match group,list
			if bail:
				print("going to next target")
				continue #go to next target
			for i in mastershocks:
				i.isexcluded = true
			var a = []
			if !get_parent().p2flag.LookForTop(a):
				for i in list:
					i.isexcluded = false
				for i in mastershocks:
					i.isexcluded = false
				print("would have dropped flag, going to next target")
				continue
				#bail
			
			for i in mastershocks:
				i.isexcluded = false
			goodorbs[target] = mastershocks.size()
			
			
			for i in list:
				i.isexcluded = false
		else:
			print("match group not big enough, next target")
			continue
	if(goodorbs.keys().size() > 0):
		print("There are good orbs")
		var biggest = goodorbs.keys()[0]
		
		for key in goodorbs.keys():
			print(key.get_name() + " with " + str(goodorbs[key]) + " shocks")
			if goodorbs[key] >= goodorbs[biggest]:
				biggest = key
		print("returning " + biggest.get_name())
		return biggest
	else:
		print("No good orbs, returning null")
		return null