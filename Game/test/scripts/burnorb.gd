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
	get_node("AnimationPlayer").play("burn")
	set_fixed_process(true)
