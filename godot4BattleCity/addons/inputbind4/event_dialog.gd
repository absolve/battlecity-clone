extends PopupPanel

enum InputTypes { KEYBOARD, MOUSE, JOY_BUTTON, JOY_AXIS }
@onready var deviceID=$VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer2/deviceID
@onready var optionButton=$VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer2/OptionButton2
@onready var lineEdit=$VBoxContainer/MarginContainer/LineEdit
@onready var label=$VBoxContainer/Label
@onready var btnName=$VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/name
@onready var btnOk=$VBoxContainer/MarginContainer3/HBoxContainer/ok
@onready var btnContainer=$VBoxContainer/MarginContainer2

var useEvent:InputEvent=null
@export var modes:InputTypes=InputTypes.KEYBOARD

func _ready():
	set_process_input(false)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			useEvent=event
			lineEdit.text=OS.get_keycode_string(event.get_keycode_with_modifiers())
			btnOk.disabled=false
			set_input_as_handled()

func setMode(mode):
	if mode==InputTypes.KEYBOARD:
		lineEdit.visible=true
		btnContainer.visible=false
		label.visible=true
		btnOk.disabled=true
		label.text=str('Please select key')
	elif mode==	InputTypes.MOUSE:
		lineEdit.visible=false
		btnContainer.visible=true
		btnOk.disabled=false
		btnName.text=str("mouse button index")
		label.text=str('Please confirm')
		deviceID.clear()
		for i in range(InputBind.DEVICE_ID_LIST.size()):
			deviceID.add_item(InputBind.DEVICE_ID_LIST[i],i-1)
		deviceID.select(1)		
		optionButton.clear()
		for i in range(InputBind.MOUSE_BTN_NAME.size()):
			optionButton.add_item(InputBind.MOUSE_BTN_NAME[i],i)
	elif mode==	InputTypes.JOY_BUTTON:
		lineEdit.visible=false
		btnContainer.visible=true
		btnOk.disabled=false
		btnName.text=str("joy button index")
		label.text=str('Please confirm')
		deviceID.clear()
		for i in range(InputBind.DEVICE_ID_LIST.size()):
			deviceID.add_item(InputBind.DEVICE_ID_LIST[i],i-1)
		deviceID.select(1)		
		optionButton.clear()
		for i in range(InputBind.JOY_BTN_NAME.size()):
			optionButton.add_item(str(i,':',InputBind.JOY_BTN_NAME[i]),i)
	elif mode==	InputTypes.JOY_AXIS:	
		lineEdit.visible=false
		btnContainer.visible=true
		btnOk.disabled=false
		btnName.text=str("joy axis index")
		label.text=str('Please confirm')
		deviceID.clear()
		for i in range(InputBind.DEVICE_ID_LIST.size()):
			deviceID.add_item(InputBind.DEVICE_ID_LIST[i],i-1)
		deviceID.select(1)	
		optionButton.clear()	
		for i in range(InputBind.JOY_AXIS_NAME.size()):
			optionButton.add_item(str('axis:',i/ 2,' ',InputBind.JOY_AXIS_NAME[i]),i)
	self.modes=mode	
	
	


func _on_about_to_popup() -> void:
	useEvent=null
	if modes==InputTypes.KEYBOARD:
		lineEdit.text=''
		set_process_input(true)


func _on_popup_hide() -> void:
	set_process_input(false)


func _on_ok_pressed() -> void:
	if modes==InputTypes.KEYBOARD:
		InputBind.emit_signal("setEvent",useEvent)
	elif modes==	InputTypes.MOUSE:
		useEvent=InputEventMouseButton.new()
		useEvent.button_index=optionButton.get_selected_id()
		useEvent.device=deviceID.get_selected_id()
		InputBind.emit_signal("setEvent",useEvent)
	elif modes==	InputTypes.JOY_BUTTON:
		useEvent=InputEventJoypadButton.new()
		useEvent.button_index=optionButton.get_selected_id()	
		useEvent.device=deviceID.get_selected_id()
		InputBind.emit_signal("setEvent",useEvent)
	elif modes==	InputTypes.JOY_AXIS:		
		useEvent=InputEventJoypadMotion.new()
		useEvent.device=deviceID.get_selected_id()
		useEvent.axis=optionButton.get_selected_id()/ 2
		useEvent.axis_value=-1.0 if optionButton.get_selected_id() % 2 == 0 else 1.0
		InputBind.emit_signal("setEvent",useEvent)
	hide()


func _on_cancel_pressed() -> void:
	hide()
