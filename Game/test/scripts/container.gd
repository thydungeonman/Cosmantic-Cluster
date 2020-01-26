extends Node2D
#Container class 
#holds up to 3 orbs in a queue like fashion. 
#Pressing s will push back
#pressing q will push back and pop front
#The three orbs that are stored will be represented with sprites with top middle and bottom positions

const YELLOW = "res://test/sprites/yellow orb.png"
const BLUE = "res://test/sprites/blue orb.png"
const ORANGE = "res://test/sprites/orange orb.png"
const PURPLE = "res://test/sprites/purple orb.png"
const BLACK = "res://test/sprites/black orb.png"
const GREEN = "res://test/sprites/green orb.png"
const WHITE = "res://test/sprites/white orb.png"
const RED = "res://test/sprites/red orb.png"

#sprites
onready var orb1 = get_node("orb1")
onready var orb2 = get_node("orb2")
onready var orb3 = get_node("orb3")

var orbs = []


func _ready():
	pass

func IsFull():
	return orbs.size() == 3
func IsEmpty():
	return orbs.size() == 0

#give container an orb to store before its full
func TakeOrb(neworb):
	if(orbs.size() < 4):
		orbs.push_back(neworb)
		DisplayOrbs()

#swap an orb with the full container
func Swap(neworb):
	orbs.push_back(neworb)
	var oldorb = orbs[0]
	orbs.pop_front()
	DisplayOrbs()
	return oldorb

func DisplayOrbs():
	for i in range(orbs.size()):
		if(i == 0):
			orb1.set_texture(orbs[0].get_node("Sprite").get_texture())
		if(i == 1):
			orb2.set_texture(orbs[1].get_node("Sprite").get_texture())
		if(i == 2):
			orb3.set_texture(orbs[2].get_node("Sprite").get_texture())

func Reset():
	orb1.set_texture(null)
	orb2.set_texture(null)
	orb3.set_texture(null)
	orbs.clear()

func GetOrbs():
	return orbs