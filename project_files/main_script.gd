extends Node3D

var webxr_interface
@onready var action_label: Label3D = $XROrigin3D/LeftController/ActionLabel
@onready var left_controller: XRController3D = $XROrigin3D/LeftController

func _ready() -> void:
	$CanvasLayer.visible = false
	$CanvasLayer/Button.pressed.connect(self._on_button_pressed)

	webxr_interface = XRServer.find_interface("WebXR")
	if webxr_interface:
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)

		webxr_interface.select.connect(self._webxr_on_select)
		webxr_interface.selectstart.connect(self._webxr_on_select_start)
		webxr_interface.selectend.connect(self._webxr_on_select_end)

		webxr_interface.squeeze.connect(self._webxr_on_squeeze)
		webxr_interface.squeezestart.connect(self._webxr_on_squeeze_start)
		webxr_interface.squeezeend.connect(self._webxr_on_squeeze_end)

		webxr_interface.is_session_supported("immersive-vr")

	# Łączenie sygnałów przycisków kontrolera [cite: 4]
	left_controller.button_pressed.connect(self._on_left_controller_button_pressed)
	left_controller.button_released.connect(self._on_left_controller_button_released)

func _webxr_session_supported(session_mode: String, supported: bool) -> void:
	if session_mode == 'immersive-vr':
		if supported:
			$CanvasLayer.visible = true
		else:
			OS.alert("Your browser doesn't support VR")

func _on_button_pressed() -> void:
	webxr_interface.session_mode = 'immersive-vr'
	webxr_interface.requested_reference_space_types = 'bounded-floor, local-floor, local'
	webxr_interface.required_features = 'local-floor'
	webxr_interface.optional_features = 'bounded-floor'

	if not webxr_interface.initialize():
		OS.alert("Failed to initialize WebXR")
		return

func _webxr_session_started() -> void:
	$CanvasLayer.visible = false
	get_viewport().use_xr = true
	print ("Reference space type: " + webxr_interface.reference_space_type)

func _webxr_session_ended() -> void:
	$CanvasLayer.visible = true
	get_viewport().use_xr = false

func _webxr_session_failed(message: String) -> void:
	OS.alert("Failed to initialize: " + message)

func _on_left_controller_button_pressed(button: String) -> void:
	print ("Button pressed: " + button)
	
	# Wyświetlanie nazwy na etykiecie 3D
	if action_label:
		action_label.text = "Wcisnieto: " + button
	
	# Start celowania teleportem po wciśnięciu triggera
	if button == "trigger_click":
		if left_controller.has_method("start_aiming"):
			left_controller.start_aiming()

func _on_left_controller_button_released(button: String) -> void:
	print ("Button release: " + button)
	
	# Wyświetlanie nazwy na etykiecie 3D
	if action_label:
		action_label.text = "Puszczono: " + button
		
	# Wykonanie teleportacji po puszczeniu triggera
	if button == "trigger_click":
		if left_controller.has_method("teleport_now"):
			left_controller.teleport_now()
		
		# Zatrzymanie celowania (ukrycie linii/markera)
		if left_controller.has_method("stop_aiming"):
			left_controller.stop_aiming()

func _process(_delta: float) -> void:
	var thumbstick_vector: Vector2 = left_controller.get_vector2("thumbstick")
	if thumbstick_vector != Vector2.ZERO:
		# Logowanie pozycji drążka [cite: 14]
		pass 

func _webxr_on_select(input_source_id: int) -> void:
	var tracker: XRPositionalTracker = webxr_interface.get_input_source_tracker(input_source_id)
	var xform = tracker.get_pose('default').transform

func _webxr_on_select_start(input_source_id: int) -> void:
	pass

func _webxr_on_select_end(input_source_id: int) -> void:
	pass

func _webxr_on_squeeze(input_source_id: int) -> void:
	pass

func _webxr_on_squeeze_start(input_source_id: int) -> void:
	pass

func _webxr_on_squeeze_end(input_source_id: int) -> void:
	pass
