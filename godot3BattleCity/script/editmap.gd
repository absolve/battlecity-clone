extends Node2D

var tile=preload("res://scene/tile.tscn")

var offset=Vector2(32,16)
var cellSize=16	#每个格子的大小是16px
var mapRect  #地图大小
var isPress=false #是否按下按键
var itemType={'typeA':[{'x':0,'y':0,'type':Game.brickType.WALL}]
			,'typeB':[{'x':0,'y':0,'type':Game.brickType.STONE}],
			'typeC':[{'x':0,'y':0,'type':Game.brickType.WATER}],
			'typeD':[{'x':0,'y':0,'type':Game.brickType.BUSH}],
			'typeE':[{'x':0,'y':0,'type':Game.brickType.ICE}],
			'typeF':[{'x':0,'y':0,'type':Game.brickType.WALL},{'x':1,'y':0,'type':Game.brickType.WALL},
			{'x':0,'y':1,'type':Game.brickType.WALL},{'x':1,'y':1,'type':Game.brickType.WALL}],
			'typeG':[{'x':0,'y':0,'type':Game.brickType.WALL},{'x':0,'y':1,'type':Game.brickType.WALL}],
			'typeH':[{'x':0,'y':0,'type':Game.brickType.STONE},{'x':1,'y':0,'type':Game.brickType.STONE},
			{'x':0,'y':1,'type':Game.brickType.STONE},{'x':1,'y':1,'type':Game.brickType.STONE}],
			'typeJ':[{'x':0,'y':0,'type':Game.brickType.WATER},{'x':0,'y':1,'type':Game.brickType.WATER},
			{'x':1,'y':0,'type':Game.brickType.WATER},{'x':1,'y':1,'type':Game.brickType.WATER}],
			'typeI':[{'x':0,'y':0,'type':Game.brickType.BUSH},{'x':0,'y':1,'type':Game.brickType.BUSH},
			{'x':1,'y':0,'type':Game.brickType.BUSH},{'x':1,'y':1,'type':Game.brickType.BUSH}],
			'typeL':[{'x':0,'y':0,'type':Game.brickType.ICE},{'x':0,'y':1,'type':Game.brickType.ICE},
			{'x':1,'y':0,'type':Game.brickType.ICE},{'x':1,'y':1,'type':Game.brickType.ICE}],
			}
			
#基地旁的方块
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]
	
var currentItem=''
onready var childNode=$child
onready var itemList=$Control/ItemList

func _ready():
	VisualServer.set_default_clear_color('#000')
	mapRect =Rect2(offset,Vector2(cellSize*26,cellSize*26))
	for i in baseBrickPos:
		var temp=tile.instance()
		temp.type=Game.brickType.WALL 
		temp.position.x=i['x']*cellSize+cellSize/2+offset.x
		temp.position.y=i['y']*cellSize+cellSize/2+offset.y
		temp.mapPos=Vector2(i['x'],i['y'])
		childNode.add_child(temp)
	var del=load("res://sprite/del.png")
	var wall=load("res://sprite/brick.png")
	var stone=load("res://sprite/stone.png")
	var water=load("res://sprite/water1.png")
	var bush=load("res://sprite/bush.png")
	var ice=load("res://sprite/ice.png")
	var wall1=load("res://sprite/wall1.png")
	var stone1=load("res://sprite/stone1.png")
	var water1=load("res://sprite/water4.png")
	var bush1=load("res://sprite/bush1.png")
	var ice1=load("res://sprite/ice1.png")
	itemList.add_icon_item(del)	
	itemList.add_icon_item(wall)	
	itemList.add_icon_item(stone)
	itemList.add_icon_item(water)
	itemList.add_icon_item(bush)
	itemList.add_icon_item(ice)
	itemList.add_icon_item(wall1)
	itemList.add_icon_item(stone1)	
	itemList.add_icon_item(water1)		
	itemList.add_icon_item(bush1)		
	itemList.add_icon_item(ice1)		


		
#载入地图
func loadMap(filePath:String):
	for i in childNode.get_children():
		childNode.remove_child(i)
	var file = File.new()
	print(filePath)
	if file.file_exists(filePath):
		file.open(filePath, File.READ)
		var currentLevel=parse_json(file.get_as_text())
		file.close()
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:
				var temp=tile.instance()
				temp.position.x=i['x']*cellSize+cellSize/2+offset.x
				temp.position.y=i['y']*cellSize+cellSize/2+offset.y
				temp.type=i['type']
				childNode.add_child(temp)
	else:
		print('文件不存在')			


#添加方块	
func addItem(pos):
	
	pass

#检查方块
func checkItem(pos:Vector2):
	var node=null
	pos-=offset
	var indexX=int(pos.x)/cellSize
	var indexY=int(pos.y)/cellSize
	for i in childNode.get_children():
		if i.mapPos.x==indexX&&i.mapPos.y==indexY:
			node=i
			break
	return 	node	


#删除方块
func clearItem():
	
	pass

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT &&  event.pressed:
			isPress=true
			if mapRect.has_point(get_global_mouse_position()):
				
				pass
		elif !event.pressed:
			isPress=false
	elif event is InputEventMouseMotion:	#移动
		if isPress:		
			pass


func _draw():
	for i in range(27):
		draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)
	for i in range(27):
		draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)
	


func _on_ItemList_item_selected(index):
	pass # Replace with function body.
