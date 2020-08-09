extends Node2D


enum CHAR {ENA,ETHAN,ARNIE,MILISSA,TAMBRE,KOTA,GRUMPLE,CHROSNOW,ALISIA,MACCUS,KURTIS,JOKER,JASPER,CARL,GRIFFENHOOD,OSCAR,LUCY,CRANIAL,DAEGEL,SEILITH}
var spritepaths = ["res://characters/character art/Ena final.png","res://characters/character art/Ethan final.png",
"res://characters/character art/Amie and Aziz final.png","res://characters/character art/Milissa final.png",
"res://characters/character art/Tambre final.png","res://characters/character art/Kota final.png",
"res://characters/character art/Grumple Volcano final.png","res://characters/character art/Chrosnow final.png",
"res://characters/character art/Alisia final.png","res://characters/character art/Maccus final.png",
"res://characters/character art/Kurtis final.png","res://characters/character art/Joker final.png",
"res://characters/character art/Jasper final.png","res://characters/character art/Carl final.png",
"res://characters/character art/Griffenhood final.png","res://characters/character art/Oscar final.png",
"res://characters/character art/Lucy final.png","res://characters/character art/Dr. Cranial final.png",
"res://characters/character art/Daegel final.png","res://characters/character art/Seilith final with glow.png"]

onready var player1choice = get_node("player1choice")
onready var player2choice = get_node("player2choice")

onready var player1name = get_node("player1name")
onready var player2name = get_node("player2name")

var mipmapson  = true # 0 for off
var holding = false

var player1currentpath = ""

var player1hover = [1,0]
var player2hover = [2,0]

var player1pressing = false
var player2pressing = false
var characters = []

#var loader = ResourceLoader.load_interactive("res://characters/character art/Ena final.png")

var thread
var mutex
var sem

var time_max = 100 # msec

var queue = []
var pending = {}

var loading = false
var loadtimer = 0.0
var loadtime = .1

func _ready():
	var children = get_children()
	for child in children:
		if(child.is_in_group("character")):
			characters.push_back(child)
	for i in range(20):
		var charnode = preload("res://test/scenes/character orb.tscn").instance()
		characters[i].add_child(charnode)
		charnode.character = i
	
	var array = []
	var count = 0
	for y in range(5):
		for x in range(5):
			if(x == 0 and y == 0) or (x == 4 and y == 0) or (x == 0 and y == 4) or (x == 4 and y == 4) or x == 2 and y == 2:
				continue
			characters[count].get_child(0).position = [x,y]
			characters[count].get_child(0).spritepath = spritepaths[count]
			characters[count].get_child(0).name = characters[count].get_name()
			count += 1
	for i in characters:
#		i.get_child(0).spritepath = spritepaths[]
		print(i.get_name())
		print(i.get_child(0).name)
		print(i.get_child(0).spritepath)
		i.get_child(0).sprite = load(i.get_child(0).spritepath)
	set_fixed_process(true)
	set_process(true)
#	resource_queue.start()



func _process(delta):
	pass
#	if loading:
#		loadtimer += delta
#		if loadtimer > loadtime:
#			loadtimer = 0.0
#			loading = false
	
				

func _fixed_process(delta):
#	print(str(get_progress(player1currentpath)))
	
	if(Input.is_action_pressed("ui_accept")):
		get_tree().change_scene("res://test/testboard.tscn")
	
	
	
	
	if(Input.is_action_pressed("ui_select")):
		if(!holding):
			if(mipmapson):
				get_node("Label").set_text("mipmaps: ON")
			else:
				get_node("Label").set_text("mipmaps: OFF")
			holding = true
			for i in characters:
				i.get_child(0).sprite.set_flags(mipmapson)
			mipmapson = !mipmapson
	else:
		holding = false
	
	
	if(Input.is_action_pressed("ui_left")):
		#go left
		if(!player2pressing):
			var found = false
			if(player2hover == [3,2]):
				player2hover[0] -= 2
			else:
				player2hover[0] -= 1
			if(player2hover[0] < 0):
				player2hover[0] = 0
			player2pressing = true
			print(player2hover)
			for char in characters:
				if(char.get_child(0).position == player2hover):
					get_node("p2select").set_global_pos(char.get_child(0).get_global_pos())
					player2choice.set_texture(char.get_child(0).sprite)
					player2name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player2hover[0] += 1
	elif(Input.is_action_pressed("ui_right")):
		#go right
		if(!player2pressing):
			var found = false
			if(player2hover == [1,2]):
				player2hover[0] += 2
			else:
				player2hover[0] += 1
			player2pressing = true
			print(player2hover)
			for char in characters:
				if(char.get_child(0).position == player2hover):
					get_node("p2select").set_global_pos(char.get_child(0).get_global_pos())
					player2choice.set_texture(char.get_child(0).sprite)
					player2name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player2hover[0] -= 1
	elif(Input.is_action_pressed("ui_down")):
		#go dowm
		if(!player2pressing):
			var found = false
			if(player2hover == [2,1]):
				player2hover[1] += 2
			else:
				player2hover[1] += 1
			player2pressing = true
			for char in characters:
				if(char.get_child(0).position == player2hover):
					get_node("p2select").set_global_pos(char.get_child(0).get_global_pos())
					player2choice.set_texture(char.get_child(0).sprite)
					player2name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player2hover[1] -= 1
			print(player2hover)
	elif(Input.is_action_pressed("ui_up")):
		#go up
		var found = false
		if(!player2pressing):
			if(player2hover == [2,3]):
				player2hover[1] -= 2
			else:
				player2hover[1] -= 1
			player2pressing = true
			for char in characters:
				if(char.get_child(0).position == player2hover):
					get_node("p2select").set_global_pos(char.get_child(0).get_global_pos())
					player2choice.set_texture(char.get_child(0).sprite)
					player2name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player2hover[1] += 1
			print(player2hover)
	else:
		player2pressing = false
	
	
	if(Input.is_action_pressed("p1_aim_left")):
		#go left
		if(!player1pressing):
			var found = false
			if(player1hover == [3,2]):
				player1hover[0] -= 2
			else:
				player1hover[0] -= 1
			if(player1hover[0] < 0):
				player1hover[0] = 0
			player1pressing = true
			print(player1hover)
			for char in characters:
				if(char.get_child(0).position == player1hover):
					get_node("p1select").set_global_pos(char.get_child(0).get_global_pos())
					player1choice.set_texture(char.get_child(0).sprite)
					player1name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player1hover[0] += 1
	elif(Input.is_action_pressed("p1_aim_right")):
		#go right
		if(!player1pressing):
			var found = false
			if(player1hover == [1,2]):
				player1hover[0] += 2
			else:
				player1hover[0] += 1
			player1pressing = true
			print(player1hover)
			for char in characters:
				if(char.get_child(0).position == player1hover):
					get_node("p1select").set_global_pos(char.get_child(0).get_global_pos())
					player1choice.set_texture(char.get_child(0).sprite)
					player1name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player1hover[0] -= 1
	elif(Input.is_action_pressed("p1_store")):
		#go dowm
		if(!player1pressing):
			var found = false
			if(player1hover == [2,1]):
				player1hover[1] += 2
			else:
				player1hover[1] += 1
			player1pressing = true
			for char in characters:
				if(char.get_child(0).position == player1hover):
					get_node("p1select").set_global_pos(char.get_child(0).get_global_pos())
					player1choice.set_texture(char.get_child(0).sprite)
					player1name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player1hover[1] -= 1
			print(player1hover)
			loading = true
	elif(Input.is_action_pressed("p1_fire")):
		#go up
		var found = false
		if(!player1pressing):
			if(player1hover == [2,3]):
				player1hover[1] -= 2
			else:
				player1hover[1] -= 1
			player1pressing = true
			for char in characters:
				if(char.get_child(0).position == player1hover):
					get_node("p1select").set_global_pos(char.get_child(0).get_global_pos())
					player1choice.set_texture(char.get_child(0).sprite)
					player1name.set_text(char.get_child(0).name)
					found = true
					break
			if(!found):
				player1hover[1] += 1
			print(player1hover)
	else:
		player1pressing = false
