extends Node
class_name SpeedforceComponent

const SPEEDFORCE_AP_COST: float = 30.0
var is_speedforce_active: bool = false

# Khai báo biến để lưu Node Player (cha)
var player: CharacterBody2D

func _ready() -> void:
	# Lấy Node cha (chính là Player đang chứa Scene này)
	player = get_parent()

func _physics_process(_delta: float) -> void:
	# Kiểm tra an toàn xem Node cha có phải là Player hợp lệ không
	if not player or not player.is_alive: return
	
	# Nhận nút bấm kích hoạt chiêu (Ví dụ: phím Space)
	if Input.is_action_just_pressed("ui_accept"):
		if is_speedforce_active: return
		
		# Kiểm tra và trừ AP trực tiếp trên Player cha
		if player.current_ap < SPEEDFORCE_AP_COST:
			player.show_message("Not enough AP!", Color.RED)
			return
			
		player.current_ap -= SPEEDFORCE_AP_COST
		activate_speedforce()

func activate_speedforce() -> void:
	is_speedforce_active = true
	
	# Ép biến speed của Player cha tăng gấp 3 lần!
	player.speed = player.BASE_SPEED * 3
	player.show_message("Speedforce Activated!", Color.YELLOW)
	
	# Tạo bộ đếm thời gian tồn tại chiêu
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_on_speedforce_timeout)
	
	print("Activate Speed Force!!!")

func _on_speedforce_timeout() -> void:
	if player:
		player.speed = player.BASE_SPEED
		player.show_message("Speedforce Ended", Color.WHITE)
	is_speedforce_active = false
