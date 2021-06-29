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

var colour
onready var sprite = get_node("Sprite")


func changeColour(colour):
	if(colour == COLOUR.RED):
		sprite.set_texture(load(RED))
	elif(colour == COLOUR.YELLOW):
		sprite.set_texture(load(YELLOW))
	elif(colour == COLOUR.BLUE):
		sprite.set_texture(load(BLUE))
	elif(colour == COLOUR.ORANGE):
		sprite.set_texture(load(ORANGE))
	elif(colour == COLOUR.PURPLE):
		sprite.set_texture(load(PURPLE))
	elif(colour == COLOUR.BLACK):
		sprite.set_texture(load(BLACK))
	elif(colour == COLOUR.GREEN):
		sprite.set_texture(load(GREEN))
	elif(colour == COLOUR.WHITE):
		sprite.set_texture(load(WHITE))
	elif(colour == COLOUR.GREY):
		sprite.set_texture(load(GREY))

func setRot(rotation):
	sprite.set_rot(rotation)

func _ready():
	#get appropriate rotation and sprite
	#start fall animation
	get_node("AnimationPlayer").play("burn")
	set_fixed_process(true)
