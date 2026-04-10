extends "res://script/tank.gd"

# 玩家相关变量
var playerId=Game.playerId.p1  # 玩家ID，用来区分按键
var bullet=preload("res://scene/bullet.tscn")  # 子弹预制体
var explode=preload("res://scene/explode.tscn")  # 爆炸预制体
var objType=Game.objType.PLAYER  # 对象类型
var level=Game.level.MIN  # 玩家坦克级别
var keymap={"up":0,"down":0,"left":0,"right":0,'shoot':0}  # 按键映射
var greenColor=['#0d472f','#d9ffe7','#5ea77b']  # 外表颜色

# 音效节点
onready var fireSound=$fire  # 开火音效
onready var hitSound=$hit  # 被击中音效
onready var idleSound=$idle  #  idle音效
onready var walkSound=$walk  # 行走音效
onready var slideSound=$slide  # 滑行音效

# 初始化函数
func _ready():
	collision_layer=1  # 碰撞层
	collision_mask=8  # 碰撞掩码
	speed=80  # 移动速度	
	startInit()  # 开始初始化
	
	# 设置按键映射
	if playerId==Game.playerId.p1:
		keymap["up"]="p1_up"
		keymap["down"]="p1_down"
		keymap["left"]="p1_left"
		keymap["right"]="p1_right"
		keymap["shoot"]="p1_shoot"
	elif playerId==Game.playerId.p2:
		keymap["up"]="p2_up"
		keymap["down"]="p2_down"
		keymap["left"]="p2_left"
		keymap["right"]="p2_right"
		keymap["shoot"]="p2_shoot"	
		an.material.set_shader_param('ischange',true)  # 改变玩家2的颜色

# 物理过程处理
func _physics_process(delta):
	if state==Game.tankstate.START:  # 如果坦克状态为开始
		lastDir=dir  # 记录上一个方向
		isStop=false  # 是否停止移动
	
		# 处理方向输入
		if Input.is_action_pressed(keymap["down"]):
			if vec==Vector2.ZERO&&isOnIce:  # 之前的是停下来并且在冰上
				slideSound.play()  # 播放滑行音效
			vec=Vector2(0,speed)  # 设置速度向量
			dir=Game.dir.DOWN  # 设置方向
		elif Input.is_action_pressed(keymap["up"]):
			if vec==Vector2.ZERO&&isOnIce:  # 之前的是停下来并且在冰上
				slideSound.play()  # 播放滑行音效
			vec=Vector2(0,-speed)  # 设置速度向量
			dir=Game.dir.UP  # 设置方向
		elif Input.is_action_pressed(keymap["left"]):
			if vec==Vector2.ZERO&&isOnIce:  # 之前的是停下来并且在冰上
				slideSound.play()  # 播放滑行音效
			vec=Vector2(-speed,0)  # 设置速度向量
			dir=Game.dir.LEFT  # 设置方向
		elif Input.is_action_pressed(keymap["right"]):
			if vec==Vector2.ZERO&&isOnIce:  # 之前的是停下来并且在冰上
				slideSound.play()  # 播放滑行音效
			vec=Vector2(speed,0)  # 设置速度向量
			dir=Game.dir.RIGHT  # 设置方向
		else:
			vec=Vector2.ZERO  # 停止移动	
			
		if lastDir!=dir:  # 转向的需要修改位置
			turnDirection()
		
		# 处理开火输入
		if Input.is_action_pressed(keymap["shoot"]):
			fire()
		
		# 处理动画
		animation(dir,vec)		

		# 获取碰撞区域
		var areas=[]
		if dir==Game.dir.LEFT:
			areas=leftArea.get_overlapping_areas()
		elif dir==Game.dir.RIGHT:
			areas=rightArea.get_overlapping_areas()
		elif dir==Game.dir.UP:
			areas=topArea.get_overlapping_areas()
		elif dir==Game.dir.DOWN:
			areas=bottomArea.get_overlapping_areas()

		isOnIce=false	
		# 处理碰撞
		for i in areas:
			if i == leftArea||i ==rightArea||i==topArea\
			||i==bottomArea||i==self:
				continue
			# 处理与砖块和基地的碰撞
			if i.get('objType') in [Game.objType.BRICK,Game.objType.BASE]:
				var type=i.get('type')
				if type==Game.brickType.BUSH||type==Game.brickType.ICE:
					if type==Game.brickType.ICE:
						isOnIce=true  # 在冰上
					continue
				if type==Game.brickType.WATER&&hasShip:
					continue  # 有船可以在水上行驶	
				isStop=true  # 碰到障碍物，停止移动
			# 处理与其他坦克的碰撞
			if i.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER]:
				if global_position.distance_to(i.global_position)<10:
					continue  # 距离太近，忽略
				isStop=true  # 碰到其他坦克，停止移动
					
		# 处理音效
		if vec!=Vector2.ZERO:
			slideTime=20  # 重置滑行时间
			if !walkSound.playing:
				walkSound.play()  # 播放行走音效
			if idleSound.playing:
				idleSound.stop()  # 停止 idle音效
		else:
			if walkSound.playing:
				walkSound.stop()  # 停止行走音效
			if !idleSound.playing:
				idleSound.play()  # 播放 idle音效	
		
			
		# 处理冰上滑行
		if isOnIce&&slideTime>0&&vec==Vector2.ZERO:  # 冰块上继续滑行
			if dir==Game.dir.LEFT:
				vec=Vector2(-speed,0)
			elif dir==Game.dir.RIGHT:
				vec=Vector2(speed,0)
			elif dir==Game.dir.UP:
				vec=Vector2(0,-speed)
			elif dir==Game.dir.DOWN:
				vec=Vector2(0,speed)
			slideTime-=1  # 减少滑行时间
			
		# 移动坦克
		if !isStop:
			position+=vec*delta			
			
		# 边界检查
		if position.x<=tankSize/2:
			position.x=tankSize/2  # 左边界
		if position.x>=mapSize.x-tankSize/2:	
			position.x=mapSize.x-tankSize/2  # 右边界

		if position.y<=tankSize/2:
			position.y=tankSize/2  # 上边界
		if position.y>=mapSize.y-tankSize/2:	
			position.y=mapSize.y-tankSize/2  # 下边界



# 改变方向的时候调整位置，设置成16px的倍数
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16  # 水平方向移动时，调整y坐标
	else:
		position.x=round((position.x)/16)*16  # 垂直方向移动时，调整x坐标


# 发射子弹
func fire():
	if canShoot:  # 如果可以开火
		# 清理无效的子弹对象
		var del=[]
		for i in bullets:  # 清理无效对象
			if not is_instance_valid(i):
				del.append(i)
		for i in del:
			bullets.remove(bullets.find(i))	
		
		if bullets.size()>=bulletMax:  # 子弹数量达到上限
			return
		
		canShoot=false  # 禁用开火
		shootTimer.start()  # 启动射击计时器
		
		# 创建子弹
		var temp=bullet.instance()
		temp.position=position  # 设置子弹位置
		temp.dir=dir  # 设置子弹方向
		temp.playerId=playerId  # 设置玩家ID
		temp.own=Game.objType.PLAYER  # 设置子弹所有者
		temp.setPower(bulletPower)  # 设置子弹威力
		temp.ownId=get_instance_id()  # 设置所有者ID
		
		bullets.append(temp)  # 添加到子弹列表
		Game.map.addBullet(temp)  # 添加到地图
		fireSound.play()  # 播放开火音效

# 添加爆炸效果
func addExplosion(isBig=true):
	var temp=explode.instance()  # 实例化爆炸效果
	temp.big=isBig  # 设置爆炸大小
	temp.position=position  # 设置爆炸位置
	temp.playSound=true  # 播放爆炸音效
	temp.own=Game.objType.PLAYER  # 设置爆炸所有者
	Game.map.addOther(temp)  # 添加到地图
		
# 开始初始化
func startInit():
	monitorable=false  # 禁用碰撞检测
	monitoring=false  # 禁用碰撞检测
	initTimer.start()  # 启动初始化计时器
	an.play('flash')  # 播放闪烁动画

# 设置是否有船（可以在水上行驶）
func setShip(flag:bool):
	hasShip=flag  # 设置是否有船
	ship.visible=flag  # 设置船的可见性
	if playerId==Game.playerId.p1:
		ship.play('0')  # 玩家1的船动画
	elif playerId==Game.playerId.p2:
		ship.play('1')  # 玩家2的船动画
		
# 升级坦克
func upgrade():
	if level==Game.level.MIN:
		level=Game.level.MEDIUM  # 升级到中等坦克
		bulletPower=Game.bulletPower.FAST  # 提高子弹速度
	elif level==Game.level.MEDIUM:
		level=Game.level.LARGE  # 升级到大型坦克
		bulletPower=Game.bulletPower.FAST  # 保持子弹速度
		bulletMax=2  # 增加子弹数量
	elif level==Game.level.LARGE:
		level=Game.level.SUPER  # 升级到超级坦克
		bulletPower=Game.bulletPower.SUPER  # 提高子弹威力
		bulletMax=2  # 保持子弹数量

# 直接升级到最高级坦克
func upgrade2Max():
	level=Game.level.SUPER  # 直接设置为超级坦克
	bulletPower=Game.bulletPower.SUPER  # 最高级子弹威力
	bulletMax=2  # 最大子弹数量
	armour=1  # 增加装甲

# 设置坦克是否冻结
func setFreeze(flag=true):
	if flag:
		isFreeze=flag  # 设置冻结状态
		state=Game.tankstate.FREEZE  # 设置坦克状态为冻结
		if ani.animation!='flash':
			an.stop()  # 停止动画
			idleSound.stop()  # 停止 idle音效
			walkSound.stop()  # 停止行走音效
	else:
		isFreeze=false  # 取消冻结状态
		if initTimer.is_stopped():
			state=Game.tankstate.START  # 设置坦克状态为开始
			
# 处理动画
func animation(dir,vec):
	# 设置坦克朝向
	if dir==Game.dir.UP:
		an.flip_v=false
		an.flip_h=false
		an.rotation_degrees=0
	elif dir==Game.dir.DOWN:
		an.flip_v=true
		an.flip_h=false
		an.rotation_degrees=0
	elif dir==Game.dir.LEFT:
		an.flip_v=false
		an.flip_h=true
		an.rotation_degrees=-90
	elif dir==Game.dir.RIGHT:	
		an.flip_v=false
		an.flip_h=false
		an.rotation_degrees=90

			
	# 根据坦克级别和移动状态播放不同动画
	if vec!=Vector2.ZERO:	
		if level==Game.level.MIN:
			an.play("small_run")  # 小型坦克运行动画
		elif level==Game.level.MEDIUM:
			an.play('medium_run')  # 中型坦克运行动画	
		elif level==Game.level.LARGE:
			an.play('large_run')  # 大型坦克运行动画	
		elif level==Game.level.SUPER:
			an.play('super_run')  # 超级坦克运行动画		
	else:
		if level==Game.level.MIN:
			an.play("small")  # 小型坦克 idle动画
		elif level==Game.level.MEDIUM:
			an.play('medium')  # 中型坦克 idle动画	
		elif level==Game.level.LARGE:
			an.play('large')  # 大型坦克 idle动画	
		elif level==Game.level.SUPER:
			an.play('super')  # 超级坦克 idle动画	


# 初始化计时器超时处理
func _on_initTimer_timeout():
	if !isFreeze:
		state=Game.tankstate.START  # 设置坦克状态为开始
	else:
		animation(dir,Vector2.ZERO)  # 播放 idle动画	
	setShip(hasShip)  # 设置船的状态	
	set_deferred('monitorable',true)  # 启用碰撞检测
	set_deferred('monitoring',true)  # 启用碰撞检测
	startinvincible(3)  # 启动无敌模式，持续3秒


# 碰撞处理
func _on_tank_area_entered(area):
	if isDestroy||area==null:
		return  # 如果坦克已被摧毁或区域为空，返回
	
	# 处理子弹碰撞
	if area!=null&&area.get('objType')==Game.objType.BULLET:
		if isInvincible:
			return  # 无敌状态，忽略子弹
		if area.get('own')==Game.objType.ENEMY:  # 敌人的子弹
			if hasShip:
				setShip(false)  # 有船的话，船被摧毁
				return
			if armour>0:
				armour-=1  # 减少装甲
				if level==Game.level.SUPER:
					level=Game.level.LARGE  # 装甲被击中后降级
					bulletPower=Game.bulletPower.FAST  # 子弹威力降低
				hitSound.play()  # 播放被击中音效
			else:
				# 坦克被摧毁
				isDestroy=true  # 设置摧毁标志
				state=Game.tankstate.DEAD  # 设置坦克状态为死亡
				set_deferred('monitorable',false)  # 禁用碰撞检测
				set_deferred('monitoring',false)  # 禁用碰撞检测
				Game.emit_signal("hitPlayer",playerId)  # 发送玩家被击中信号
				visible=false  # 隐藏坦克
				addExplosion()  # 添加爆炸效果
				call_deferred('queue_free')  # 延迟释放坦克	
				
	# 处理道具碰撞
	if area!=null&&area.get('objType')==Game.objType.BONUS:
		Game.emit_signal("getBonus",area.get('type'),objType,playerId)  # 发送获得道具信号
		area.call_deferred('queue_free')  # 延迟释放道具



