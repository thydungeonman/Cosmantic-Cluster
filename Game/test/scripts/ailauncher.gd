extends Node2D


enum PLAYER {PLAYER1 = 0,PLAYER2 = 1,AI = 2}
enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

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
var clickedpos = Vector2(30,30)
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


var waittime = 1
var waitcounter = 0.0

var madeswap = false
var didstore = false

#onready var midwallpos = get_parent().get_node("middlewall").get_pos()
var bottomorbs = []
var target # orb to be aimed at

func _ready():
	set_fixed_process(true)
	next = preload("res://test/scenes/aimingreticule.tscn").instance()
	add_child(next)
	next.set_pos(Vector2(0,20))
	AimReticule()
	

func _fixed_process(delta):
#	print(get_parent().orbsonboardp2.size())
	if(Input.is_action_pressed("click")):
		if(!madeswap):
			orb = Swap(orb)
		madeswap = true
#	if(Input.is_action_pressed("rclick")):
#		if(!didstore):
#			Store(orb)
#		didstore = true
	if(Input.is_action_pressed("ui_accept")):
		state = 0
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
	if(state == 0 and loaded):#(!checkedlayer and loaded):#(!aiming and loaded):
		target = CheckBottomLayer()
		print(target)
		
	if(state == 1):
		while(state == 1):
			CheckAim(clickedpos)
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
	if(state == 4):
		if(!madeswap):
			orb = Swap(orb)
			madeswap = true
		state = 0
	
	#LASER =========================================================>O
	if(Input.is_action_pressed("laser")):
		if(!lasing):
			var las = preload("res://test/scenes/laser.tscn").instance()
			get_parent().add_child(las)
			las.set_pos(get_pos())
			las.Charge(trajectory,x)
			las.Fire()
			lasing = true
	else:
		lasing = false
	

func LoadOrb(delta):
	if(upcomingorb == null):
		randomize()
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
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		AdjustReticule()
	elif(target > x):
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
	if(laserisactive):
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
	print("fired an oeb")

func Freeze(duration):
	isfrozen = true
	frozentime = duration
	speed = 0
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
		print("SUPERIOR THROWAWAY !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return
	randomize()
	var randspot = int(randi() % 800) + 1000
	clickedpos = Vector2(randspot,515)
	print("THROWAWAY")
	print(clickedpos)
	aiming = false

#swap  orb with container
func Swap(oldorb):
	print("swapped: " + str(swapped))
	print(str(oldorb))
	print(GetStoredOrbs())
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
	print(str(neworb))
	print("MADE A SWAP")
	print(GetStoredOrbs())
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