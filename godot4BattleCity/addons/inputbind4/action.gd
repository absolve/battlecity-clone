extends VBoxContainer

@onready var _events=$events
@onready var _action=$PanelContainer/MarginContainer/HBoxContainer/action
@onready var _tip=$PanelContainer/MarginContainer/HBoxContainer/tip

var event=preload("res://addons/inputbind4/event.tscn")
var actionName=''	#动作名字
var keyName=''  #游戏中按键的名字
var tip=''  #提示

func _ready() -> void:
	_action.text=str(keyName)
	_tip.text=str(tip)
	init()
	
func init():
	var list=InputMap.action_get_events(actionName)
	for i in list:
		var temp=event.instantiate()	
		if i is InputEventKey:  #按键
			temp.eventName=str(i.as_text() ,' -Key')
		elif i is InputEventJoypadButton:	#手柄按钮
			temp.eventName=str('device:',i.device," button:",i.button_index,':',InputBind.JOY_BTN_NAME[i.button_index] ,' -JoypadButton')		
		elif i is InputEventJoypadMotion:	#摇杆
			temp.eventName=str('device:',i.device," axis:",i.axis,' ',InputBind.JOY_AXIS_NAME[i.axis] ,' -JoypadMotion')		
		elif i is InputEventMouseButton:#鼠标
			temp.eventName=str('device:',i.device," ",InputBind.MOUSE_BTN_NAME[i.button_index],' -Mouse')		
		_events.add_child(temp)
		
		var removeBtn=temp.find_children("btn")
		if removeBtn.size()>0:
			removeBtn[0].pressed.connect(removeEvent.bind(i,temp))
		
#重新设置		
func reset():
	for i in _events.get_children():
		_events.remove_child(i)
	init()
	
#删除事件
func removeEvent(event,node):
	InputMap.action_erase_event(actionName,event)
	node.queue_free()	
	
	


func _on_texture_button_pressed() -> void:
	InputBind.emit_signal("addEvent",actionName,get_global_rect(),self)
