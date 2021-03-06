extends Node2D

enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

const YELLOW = "res://test/sprites/orbs/Yellow Orb/Yellow Orb Spritesheet.png"
const BLUE = "res://test/sprites/orbs/Blue Orb/Blue Orb.png"
const ORANGE = "res://test/sprites/orbs/Orange Orb/Orange Orb.png"
const PURPLE = "res://test/sprites/orbs/Purple Orb/Purple Orb.png"
const BLACK = "res://test/sprites/orbs/Black Orb/New Piskel (1).png"
const GREEN = "res://test/sprites/orbs/Green Orb/Green Orb.png"
const WHITE = "res://test/sprites/orbs/White Orb/WhiteOrb.png"
const RED = "res://test/sprites/orbs/Red Orb/Fire Orb.png"
const GREY = "res://test/sprites/grey orb new.png"

const OYELLOW = "res://test/sprites/yellow orb.png"
const OBLUE = "res://test/sprites/blue orb.png"
const OORANGE = "res://test/sprites/orange orb.png"
const OPURPLE = "res://test/sprites/purple orb.png"
const OBLACK = "res://test/sprites/black orb.png"
const OGREEN = "res://test/sprites/green orb.png"
const OWHITE = "res://test/sprites/white orb.png"
const ORED = "res://test/sprites/red orb.png"
const OGREY = "res://test/sprites/grey orb new.png"

var colour
var right = 0
var clock = 0

var Right = false
var Clock = false

var waittime = 0.0
var waittimer = 0.0
var falling = false
var played = false

onready var sfx = get_node("SamplePlayer")
onready var sprite = get_node("Sprite")

func changeColour(colour):
	if(colour == COLOUR.RED):
		sprite.set_texture(preload(RED))
	elif(colour == COLOUR.YELLOW):
		sprite.set_texture(preload(YELLOW))
	elif(colour == COLOUR.BLUE):
		sprite.set_texture(preload(BLUE))
	elif(colour == COLOUR.ORANGE):
		sprite.set_texture(preload(ORANGE))
	elif(colour == COLOUR.PURPLE):
		sprite.set_texture(preload(PURPLE))
	elif(colour == COLOUR.BLACK):
		sprite.set_texture(preload(BLACK))
	elif(colour == COLOUR.GREEN):
		sprite.set_texture(preload(GREEN))
	elif(colour == COLOUR.WHITE):
		sprite.set_texture(preload(WHITE))
	elif(colour == COLOUR.GREY):
		get_node("Sprite").set_vframes(1)
		get_node("Sprite").set_hframes(1)
		sprite.set_texture(preload(GREY))

func setRot(rotation):
	sprite.set_rot(rotation)

func _ready():
	#get appropriate rotation and sprite
	#start fall animation
#	randomize()
	right = randi() % 2
	clock = randi() % 2
	var waittime = (randf() * .15)
	get_node("Timer").set_wait_time(waittime)
	get_node("Timer").start()
#	print(right)
#	print(clock)
#	print("RANDOMIZEEEEEEEEEEEEEEEE")
#	print(waittime)
	
	set_fixed_process(true)

func _fixed_process(delta):
	#pick fall direction and spin direction
#	print(waittimer)
#	print(waittimer < waittime)
	waittimer += delta
#	if(waittimer < waittime and !falling):
#		get_node("AnimationPlayer").play("fall")
#		falling = true
	if(falling):
		if(!played):
			sfx.play("Orb falling 02_revision")
			played = true
		if(Right):
			fallRight(delta)
		else:
			fallLeft(delta)
		if(Clock):
			spinClock(delta)
		else:
			spinAntiClock(delta)



func fallRight(delta):
	var pos = get_global_pos()
	pos.x += 60 * delta
	set_global_pos(pos)
#	print("right")
	#move slightly to the right


func fallLeft(delta):
	var pos = get_global_pos()
	pos.x -= 60 * delta
	set_global_pos(pos)
#	print("left")
	#move sligtly to the left

func spinClock(delta):
	sprite.rotate(PI * delta)
	pass
	#rotate clockwise

func spinAntiClock(delta):
	sprite.rotate(-PI* delta)
	pass
	#rotate anticlock



func _on_Timer_timeout():
	if(!falling):
		if right == 0:
			Right = true
		if clock == 0:
			Clock = true
		get_node("AnimationPlayer").play("fall")
		falling = true
		print(right)
		print(clock)
