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

var player = PLAYER.PLAYER1
onready var sfx = get_node("SamplePlayer")
onready var anim = get_node("LauncherAnimationPlayer")
onready var abilityanim = get_node("AbilityAnimationPlayer")
onready var nextorb = get_node("nextorb") # the sprite of the upcoming orb
var upcomingorb #this holds an enumeration for the upcoming orb

var trajectory = Vector2(-1500,-1500)
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
var loaded = false #must be false for the launcher to be loaded
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

onready var aim = get_node("Particles2D")
onready var container = get_node("container")
var next = null

func _ready():
	print(orb)
	set_fixed_process(true)
	#aim.set_param(0,270 - rad2deg(x))
	next = preload("res://test/scenes/aimingreticule.tscn").instance()
	add_child(next)
	next.set_pos(Vector2(0,20))
	AimReticule()
	

func _fixed_process(delta):
	LoadOrb(delta)
	if(player == PLAYER.PLAYER1):
		GetAimControlsP1(delta)
	if(player == PLAYER.PLAYER2):
		GetAimControlsP2(delta)
	if(isfrozen):
		Defrost(delta)
	if(player == PLAYER.PLAYER1 and loaded):
		GetFireControlsP1(delta)
	if(player == PLAYER.PLAYER2 and loaded):
		GetFireControlsP2(delta)
	
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
	if(shottimer > 2.0):
		if(loaded == false):
			orb = upcomingorb #make the switch
			upcomingorb = null
			print(orb)
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

func GetAimControlsP1(delta):
	if(Input.is_action_pressed("p1_aim_left")):
		#print(speed)
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)     
		aim.set_param(0,270 - rad2deg(x))
		AdjustReticule()
		#print(str(rad2deg(x)) + " " + str(tan(x)))
		#print(str(-Vector2(-1500,0).angle_to(get_local_mouse_pos())))
		#print(get_global_mouse_pos())
		#print(get_local_mouse_pos())
		sfx.play("mrown1__tick launcher aiming left or right")
	elif(Input.is_action_pressed("p1_aim_right")):
		#print(speed)
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		AdjustReticule()
		#print(str(rad2deg(x)) + " " + str(tan(x)))
		
		#print(str(-Vector2(-1500,0).angle_to(get_local_mouse_pos())))
		#print(get_global_mouse_pos())
		#print(get_local_mouse_pos())
		sfx.play("mrown1__tick launcher aiming left or right")
	else:
		speed = minspeed

func GetAimControlsP2(delta):
	if(Input.is_action_pressed("p2_aim_left")):
		#print(speed)
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x -= speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		AdjustReticule()
		#print(str(x) + " " + str(tan(x)))
		sfx.play("mrown1__tick launcher aiming left or right")
	elif(Input.is_action_pressed("p2_aim_right")):
		#print(speed)
		speed += PI/1500
		speed = clamp(speed,minspeed,maxspeed)
		x += speed
		x = clamp(x,lowerlimit,upperlimit)
		aim.set_param(0,270 - rad2deg(x))
		AdjustReticule()
		#print(str(x) + " " + str(tan(x)))
		sfx.play("mrown1__tick launcher aiming left or right")
	else:
		speed = minspeed

func GetFireControlsP1(delta):
	if(Input.is_action_pressed("p1_fire") and loaded == true): #if the key is pressed and the launcher is loaded
		if(!firing and canshoot):
			Fire()
			firing = true
			loaded = false
			shottimer = 0.0
			#get_parent().orbsonboard.push_front(orb)
			#get_parent().orbsonboardp1.push_front(orb)
			Disable()
	else:
		firing = false
	if(Input.is_action_pressed("p1_store") and !container.IsFull()):
		if(storing == false):
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			print(str(get_parent().orbsonboard.size()))
			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			print(str(get_parent().orbsonboard.size()))
			container.TakeOrb(orb)
			loaded = false
			storing = true
			sfx.play("bump - orb saved for later")
	else:
		storing = false
	
	if(Input.is_action_pressed("p1_swap") and !container.IsEmpty() and !swapped):
		if(swapping == false):
			print(str(orb))
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			orb = container.Swap(orb)
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())
			#get_parent().orbsonboard.push_front(orb)
			swapping = true
			swapped = true
			sfx.play("hurt-c-02 - orb switch")
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
			#get_parent().orbsonboard.push_front(orb)
			#get_parent().orbsonboardp2.push_front(orb)
			Disable()
			
	else:
		firing = false
	if(Input.is_action_pressed("p2_store") and !container.IsFull()):
		if(storing == false):
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it doesn't stay in the same spot and collide with new orbs
			get_parent().remove_child(orb)
			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			container.TakeOrb(orb)
			loaded = false
			storing = true
			sfx.play("bump - orb saved for later")
	else:
		storing = false
	
	if(Input.is_action_pressed("p2_swap") and !container.IsEmpty() and !swapped):
		if(swapping == false):
			print(str(orb))
			orb.set_pos(Vector2(0,-200)) #move the orb to the ether else it stays in the same spot and collides with new orbs
			get_parent().remove_child(orb)
			#get_parent().orbsonboard.remove(get_parent().orbsonboard.find(orb))
			orb = container.Swap(orb)
			get_parent().add_child(orb)
			orb.set_pos(get_global_pos())
			#get_parent().orbsonboard.push_front(orb)
			swapping = true
			swapped = true
			print(str(orb))
			sfx.play("hurt-c-02 - orb switch")
	else:
		swapping = false


func Fire():
	# if yellow ablility = true
	# spawn lightning area and child to orb
	# when orb stops check bool in orb and then activate lightning
	print(str(orb))
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
		maxspeed = standardmaxspeed
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
