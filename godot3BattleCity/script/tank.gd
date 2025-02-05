extends Node2D

var vec=Vector2.ZERO
var level=0
var state  #状态
var isInvincible=false #无敌
var speed = 70  #移动速度
var hasShip=false	#是否有船
var isFreeze=false	#冻结
var isOnIce=false  #是否在冰块上
var slideTime =20 #冰块滑动次数 每帧
var bullets=[]
var bulletMax=1	#发射最大子弹数
var life=1  #生命默认1
var dir=Game.dir.UP #方向
var lastDir=Game.dir.UP #上次的方向

onready var body=$body
onready var radar=$radar
onready var ani=$ani


