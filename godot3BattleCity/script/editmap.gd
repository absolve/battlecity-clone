extends Node2D

var tile=preload("res://scene/tile.tscn")

var offset=Vector2(32,16) #偏移
var cellSize=16	#每个格子的大小是16px
var mapRect  #地图大小
var isPress=false #是否按下按键
var itemType={'del':[],
			'typeA':[{'x':0,'y':0,'type':Game.brickType.WALL}]
			,'typeB':[{'x':0,'y':0,'type':Game.brickType.STONE}],
			'typeC':[{'x':0,'y':0,'type':Game.brickType.WATER}],
			'typeD':[{'x':0,'y':0,'type':Game.brickType.BUSH}],
			'typeE':[{'x':0,'y':0,'type':Game.brickType.ICE}],
			'typeF':[{'x':0,'y':0,'type':Game.brickType.WALL},{'x':1,'y':0,'type':Game.brickType.WALL},
			{'x':0,'y':1,'type':Game.brickType.WALL},{'x':1,'y':1,'type':Game.brickType.WALL}],
			'typeG':[{'x':0,'y':0,'type':Game.brickType.STONE},{'x':1,'y':0,'type':Game.brickType.STONE},
			{'x':0,'y':1,'type':Game.brickType.STONE},{'x':1,'y':1,'type':Game.brickType.STONE}],
			'typeH':[{'x':0,'y':0,'type':Game.brickType.WATER},{'x':0,'y':1,'type':Game.brickType.WATER},
			{'x':1,'y':0,'type':Game.brickType.WATER},{'x':1,'y':1,'type':Game.brickType.WATER}],
			'typeI':[{'x':0,'y':0,'type':Game.brickType.BUSH},{'x':0,'y':1,'type':Game.brickType.BUSH},
			{'x':1,'y':0,'type':Game.brickType.BUSH},{'x':1,'y':1,'type':Game.brickType.BUSH}],
			'typeJ':[{'x':0,'y':0,'type':Game.brickType.ICE},{'x':0,'y':1,'type':Game.brickType.ICE},
			{'x':1,'y':0,'type':Game.brickType.ICE},{'x':1,'y':1,'type':Game.brickType.ICE}],
			}
var itemMetadata=['del','typeA','typeB','typeC','typeD','typeE','typeF','typeG',
					'typeH','typeI','typeJ']
var itemImg=["res://sprite/del.png","res://sprite/brick.png","res://sprite/stone.png",
			"res://sprite/water1.png","res://sprite/bush.png","res://sprite/ice.png",
			"res://sprite/wall1.png","res://sprite/stone1.png","res://sprite/water4.png",
			"res://sprite/bush1.png","res://sprite/ice1.png"]
			
#基地旁的方块
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]
	
var currentItem=''  #当前选中的类型
onready var childNode=$child
onready var itemList=$Control/ItemList
onready var fileDialog=$Control/FileDialog
onready var loadDialog=$Control/loadDialog
onready var btnReturn=$Control/vbox/return

func _ready():
	VisualServer.set_default_clear_color('#000')
	mapRect =Rect2(offset,Vector2(cellSize*26,cellSize*26))
	addBaseBrick()
		
	for i in itemImg:
		var temp=load(i)
		itemList.add_icon_item(temp)
	for i in range(itemMetadata.size()):
		itemList.set_item_metadata(i,itemMetadata[i])
	currentItem='del'
	btnReturn.grab_focus()

#添加基地周边的方块
func addBaseBrick():
	for i in baseBrickPos:
		var temp=tile.instance()
		temp.type=Game.brickType.WALL 
		temp.position.x=i['x']*cellSize+cellSize/2+offset.x
		temp.position.y=i['y']*cellSize+cellSize/2+offset.y
		temp.mapPos=Vector2(i['x'],i['y'])
		childNode.add_child(temp)
		
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
				temp.mapPos=Vector2(i['x'],i['y'])
				childNode.add_child(temp)
	else:
		print('文件不存在')			


#添加方块	
func addItem(pos):
	pos-=offset
	var indexX=int(pos.x)/cellSize
	var indexY=int(pos.y)/cellSize
	var list=itemType[currentItem]
	print(list)
	#删除已有的方块
	for i in list:
		var node=checkItem(i.x+indexX,i.y+indexY)
		if node:
			node.queue_free()
	for i in list:
		if i['x']+indexX<0||i['x']+indexX>25:
			continue
		if i['y']+indexY<0||i['y']+indexY>25:
			continue
		var temp=tile.instance()
		temp.position.x=(i['x']+indexX)*cellSize+cellSize/2+offset.x
		temp.position.y=(i['y']+indexY)*cellSize+cellSize/2+offset.y
		temp.type=i.type
		temp.mapPos=Vector2(i['x']+indexX,i['y']+indexY)
		childNode.add_child(temp)

#检查方块
func checkItem(indexX,indexY):
	var node=null
	for i in childNode.get_children():
		if i.mapPos.x==indexX&&i.mapPos.y==indexY:
			node=i
			break
	return 	node	


#删除方块
func clearItem(pos:Vector2):
	pos-=offset
	var indexX=int(pos.x)/cellSize
	var indexY=int(pos.y)/cellSize
	
	for i in childNode.get_children():
		if i.mapPos.x==indexX&&i.mapPos.y==indexY:
			i.queue_free()

#保存到文件
func save2File(fileName):
	var data={"name":'',"data":[],"base":[],"author":"battlecity",
	"description":""}
	for i in childNode.get_children():
		var temp={'x':i.mapPos.x,'y':i.mapPos.y,'type':i.type}
		data['data'].append(temp)
	print(fileName)
	print(data)
	var file = File.new()
	file.open(fileName, File.WRITE)
	file.store_string(to_json(data))
	file.flush()
	file.close()


func _input(event):
	if fileDialog.visible||loadDialog.visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT &&  event.pressed:
			isPress=true
			if mapRect.has_point(get_global_mouse_position()):
				if currentItem=='del':
					clearItem(get_global_mouse_position())
				else:
					addItem(get_global_mouse_position())
		elif !event.pressed:
			isPress=false
	elif event is InputEventMouseMotion:	#移动
		if isPress:		
			if mapRect.has_point(get_global_mouse_position()):
				if currentItem=='del':
					clearItem(get_global_mouse_position())
				else:
					addItem(get_global_mouse_position())	


func _draw():
	for i in range(27):
		draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)
	for i in range(27):
		draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)
	


func _on_ItemList_item_selected(index):
	print(itemList.get_item_metadata(index))
	currentItem=itemList.get_item_metadata(index)



func _on_FileDialog_confirmed():
	var path=fileDialog.current_dir	
	print(path)
	print(fileDialog.current_path)
	if fileDialog.current_file:
		save2File(fileDialog.current_path)


func _on_loadDialog_file_selected(path):
	loadMap(path)


func _on_loadDialog_confirmed():
	var dir=loadDialog.current_dir
	var file=loadDialog.current_file
	if file:
		loadMap(dir+"/"+file)


func _on_load_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	loadDialog.current_dir=baseDir
	loadDialog.popup_centered()


func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()
	fileDialog.current_dir=baseDir
	fileDialog.current_file="2025.json"
	fileDialog.popup_centered()


func _on_clear_pressed():
	for i in childNode.get_children():
		i.queue_free()
	addBaseBrick()

func _on_return_pressed():
	Game.changeScene("res://scene/welcome.tscn")


func _on_FileDialog_file_selected(path):
	if fileDialog.current_file:
		save2File(fileDialog.current_path)
