extends Node2D

@export var toxicshroom_scene: PackedScene 
@export var spawn_area_rect: Rect2 = Rect2(-1500, -1000, 3000, 2000) 
@export var spawn_interval: float = 2.0  
@export var max_enemies: int = 15        

@onready var timer: Timer = $Timer

static var instance_exists = false

func _ready() -> void:
	# BƯỚC 1: DỨT ĐIỂM LỖI NHÂN BẢN
	if instance_exists:
		queue_free()
		return
	instance_exists = true
	
	# Cấu hình Timer
	timer.wait_time = spawn_interval
	timer.start()
	# Kết nối tín hiệu timeout của Timer vào code bằng lệnh
	timer.timeout.connect(_on_timer_timeout)

	# Đợi vật lý sẵn sàng
	await get_tree().physics_frame
	
	# BƯỚC 2: VÀO MAP SPAWN ĐỦ 30 CON BAN ĐẦU
	fill_to_max()

func _process(_delta: float) -> void:
	# BƯỚC 3: DEBUG HIỆN SỐ LƯỢNG (Mỗi 1 giây in 1 lần)
	if Engine.get_frames_drawn() % 60 == 0:
		var current_count = get_tree().get_nodes_in_group("enemies").size()
		print("ENEMIES: ", current_count, "/", max_enemies)

func _on_timer_timeout() -> void:
	# BƯỚC 4: KHI CHẾT (DƯỚI 30) TỰ SPAWN BÙ
	var current_count = get_tree().get_nodes_in_group("enemies").size()
	
	if current_count < max_enemies:
		spawn_toxicshroom()

func fill_to_max() -> void:
	var current = get_tree().get_nodes_in_group("enemies").size()
	while current < max_enemies:
		spawn_toxicshroom()
		current += 1

func spawn_toxicshroom() -> void:
	var pos = get_valid_spawn_position()
	var toxicshroom = toxicshroom_scene.instantiate()
	toxicshroom.position = pos
	
	toxicshroom.add_to_group("enemies") 
	get_parent().add_child.call_deferred(toxicshroom)

func get_valid_spawn_position() -> Vector2:
	# BƯỚC 5: CHECK VA CHẠM (Né Map, Hero, Quái khác)
	for i in range(25):
		var random_pos = Vector2(
			randf_range(spawn_area_rect.position.x, spawn_area_rect.end.x),
			randf_range(spawn_area_rect.position.y, spawn_area_rect.end.y)
		)
		if is_position_safe(random_pos):
			return random_pos
			
	return Vector2(randf_range(-100, 100), randf_range(-100, 100))

func is_position_safe(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	if not space_state: return true
	
	var query = PhysicsShapeQueryParameters2D.new()
	var circle_shape = CircleShape2D.new()
	# Bán kính an toàn (120px vì Hero scale 4.0 rất to)
	circle_shape.radius = 120.0 
	
	query.shape = circle_shape
	query.transform = Transform2D(0, pos)
	# Check Layer 1(Map), 2(Hero), 3(Quái) -> Tổng mask = 7
	query.collision_mask = 7 
	
	var results = space_state.intersect_shape(query)
	return results.is_empty()
