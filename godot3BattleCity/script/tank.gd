extends Node2D

var vec=Vector2.ZERO
var level=0
var state=Game.tankstate.IDLE  #状态
var isInvincible=false #无敌
var speed = 70  #移动速度
var hasShip=false	#是否有船
var isFreeze=false	#冻结
var isOnIce=false  #是否在冰块上
var slideTime =20 #冰块滑动次数 每帧
var bullets=[] #保存子弹素组
var bulletMax=1	#发射最大子弹数
var life=1  #生命默认1
var dir=Game.dir.UP #方向
var lastDir=Game.dir.UP #上次的方向
var isStop=false#是否停止
var canShoot=true #可以发射子弹
var bulletPower=Game.bulletPower.NORMAL
var tankSize=28
var armour=1  #护甲  最大4

const cellSize=16	#每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)


onready var body=$body
onready var bodyShape=$body/shape
onready var radar=$radar
onready var ani=$ani
onready var shootTimer=$shootTimer
onready var ship=$ship
onready var invincible=$invincible
onready var invincibleTimer=$invincibleTimer
onready var initTimer=$initTimer

#设置无敌
func startinvincible(time=10):
	isInvincible=true
	invincibleTimer.start(time)
	invincible.visible=true
	invincible.play("default")


func _on_shootTimer_timeout():
	canShoot=true


func _on_invincibleTimer_timeout():
	isInvincible=false
	invincible.stop()
	invincible.visible=false
