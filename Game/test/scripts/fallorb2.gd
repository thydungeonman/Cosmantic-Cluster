extends Node2D

enum COLOUR {NONE = 0,BLACK = 1,BLUE = 2,GREEN = 3,GREY = 4,
	ORANGE = 5,PURPLE = 6,RED = 7,WHITE = 8,YELLOW = 9}

const YELLOW = "res://test/sprites/yellow orb.png"
const BLUE = "res://test/sprites/blue orb.png"
const ORANGE = "res://test/sprites/orange orb.png"
const PURPLE = "res://test/sprites/purple orb.png"
const BLACK = "res://test/sprites/black orb.png"
const GREEN = "res://test/sprites/green orb.png"
const WHITE = "res://test/sprites/white orb.png"
const RED = "res://test/sprites/red orb.png"
const GREY = "res://test/sprites/grey orb new.png"

var colour
var right = 0
var clock = 0

var Right = false
var Clock = false

var waittime = 0.0
var waittimer = 0.0
var falling = false

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
		sprite.set_texture(preload(GREY))

func setRot(rotation):
	sprite.set_rot(rotation)

func _ready():
	#get appropriate rotation and sprite
	#start fall animation
	randomize()
	var right = randi() % 2
	var clock = randi() % 2
	var waittime = randf() / 20
	get_node("Timer").set_wait_time(waittime)
	get_node("Timer").start()
	if right == 0:
		Right = true
	if clock == 0:
		Clock = true
	print("RANDOMIZEEEEEEEEEEEEEEEE")
	print(waittime)
	
	set_fixed_process(true)

func _fixed_process(delta):
	#pick fall direction and spin direction
#	print(waittimer)
#	print(waittimer < waittime)
	waittimer += delta
#	if(waittimer < waittime and !falling):
#		get_node("AnimationPlayer").play("fall")
#		falling = true
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
	sprite.rotate(PI* delta)
	pass
	#rotate anticlock



func _on_Timer_timeout():
	if(!falling):
		get_node("AnimationPlayer").play("fall")
		falling = true
