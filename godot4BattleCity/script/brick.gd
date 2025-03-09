extends Area2D

@export var type=Game.brickType.WALL #类型
@export var objType=Game.objType.BRICK
@onready var ani=$ani

var blockMask=[1,1,1,1] #砖块分割成4块 上左 上右 下左 下右 1是显示 0是不显示

func _ready():
	setType(type)


#设置类型
func setType(value):
	if value==Game.brickType.WALL:
		ani.play("0")
	elif value==Game.brickType.STONE:
		ani.play("1")	
	elif value==Game.brickType.WATER:
		ani.play("2")	
	elif value==Game.brickType.BUSH:
		ani.play("3")	
		z_index=2
	elif value==Game.brickType.ICE:
		ani.play("4")	
	
#改变类型
func changeType(value):
	self.type=value
	blockMask=[1,1,1,1]
	ani.material.set_shader_parameter('block',Color(blockMask[0],
				blockMask[1],blockMask[2],blockMask[3]))	
	setType(value)	


func _on_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		if type ==Game.brickType.WALL:
#			print(area.get('dir'))
			if area.get('dir')!=null:
				var dir=area.dir
				if area.get('power')!=null && area.power==Game.bulletPower.SUPER:
					queue_free()
				if dir==Game.dir.DOWN:
					if blockMask[0]==0&&blockMask[1]==0:
						blockMask[2]=0
						blockMask[3]=0
					else:	
						blockMask[0]=0
						blockMask[1]=0
				elif dir==Game.dir.UP:
					if blockMask[2]==0&&blockMask[3]==0:
						blockMask[0]=0
						blockMask[1]=0
					else:	
						blockMask[2]=0
						blockMask[3]=0
				elif dir==Game.dir.LEFT:
					if blockMask[1]==0&&blockMask[3]==0:
						blockMask[0]=0
						blockMask[2]=0
					else:
						blockMask[1]=0
						blockMask[3]=0
				elif dir==Game.dir.RIGHT:
					if blockMask[0]==0&&blockMask[2]==0:
						blockMask[1]=0
						blockMask[3]=0
					else:	
						blockMask[0]=0
						blockMask[2]=0
				var all=0
				for i in blockMask:
					all+=i
				if all==0:
					queue_free()
					return
				ani.material.set_shader_parameter('block',Color(blockMask[0],
				blockMask[1],blockMask[2],blockMask[3]))							
		elif type==Game.brickType.STONE:
			if area.get('power')!=null && area.power==Game.bulletPower.SUPER:
				queue_free()
