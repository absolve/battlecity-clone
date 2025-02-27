extends Node2D

const cellSize=16	#每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)
var enemyCount=20 # 敌人总数
var p1LiveNum=2
var p2LiveNUm=2
var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]
var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]
#敌人复活的位置	
var enemyRevivePos=[Vector2(0,0),Vector2(12,0),Vector2(24,0)]
#基地旁的方块
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]
#基地
var basePlacePos=[Vector2(12,25),Vector2(13,25),Vector2(12,24),Vector2(13,24)]				
#基地位置
var basePos=Vector2(12,24)




func _ready():
	pass # Replace with function body.
