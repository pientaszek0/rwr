extends XRController3D

@onready var ray: RayCast3D = $TeleportRay
@onready var marker: MeshInstance3D = $TeleportMarker
var xr_origin: XROrigin3D
var xr_camera: XRCamera3D

var is_aiming: bool = false # Zmienna sprawdzająca, czy gracz celuje

func _ready() -> void:
	xr_origin = get_parent() as XROrigin3D
	xr_camera = xr_origin.get_node("XRCamera3D") as XRCamera3D
	
	# Domyślnie wyłączamy promień i znacznik
	ray.enabled = false
	marker.visible = false

# Funkcja włączająca celowanie
func start_aiming() -> void:
	is_aiming = true
	ray.enabled = true

# Funkcja wyłączająca celowanie
func stop_aiming() -> void:
	is_aiming = false
	ray.enabled = false
	marker.visible = false

func _process(_delta: float) -> void:
	# Aktualizujemy pozycję markera TYLKO gdy celujemy
	if is_aiming and ray.is_colliding():
		marker.global_transform.origin = ray.get_collision_point()
		marker.visible = true
	else:
		marker.visible = false

func teleport_now() -> void:
	# Przerywamy, jeśli gracz nie celuje lub promień w nic nie uderza
	if not is_aiming or not ray.is_colliding():
		return
		
	var target: Vector3 = ray.get_collision_point()

	var origin_tf := xr_origin.global_transform
	var cam_tf := xr_camera.global_transform
	var cam_offset := cam_tf.origin - origin_tf.origin
	
	origin_tf.origin = target - cam_offset
	xr_origin.global_transform = origin_tf
	
	# Po udanej teleportacji wyłączamy celowanie
	stop_aiming()
