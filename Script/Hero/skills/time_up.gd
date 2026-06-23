extends Node
class_name TimesUpComponent

const TIMES_UP_AP_COST: float = 25.0
var is_time_frozen: bool = false
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent()

func _physics_process(_delta: float) -> void:
	if not player or not player.is_alive: return
	
	if Input.is_action_just_pressed("ui_accept"): # Phím T
		if is_time_frozen: return
		if player.current_ap < TIMES_UP_AP_COST:
			player.show_message("Not enough AP!", Color.RED)
			return
			
		player.current_ap -= TIMES_UP_AP_COST
		activate_times_up()

func activate_times_up() -> void:
	is_time_frozen = true
	player.show_message("TIME'S UP! Freeze!", Color.AQUA)
	
	# Lấy toàn bộ quái vật trên Map và bắt chúng đứng yên
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is CharacterBody2D:
			enemy.set_physics_process(false) # Tắt hàm di chuyển đuổi theo của quái
			if enemy.has_node("AnimatedSprite2D"):
				enemy.get_node("AnimatedSprite2D").pause() # Dừng luôn hoạt ảnh animation của quái
				
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_times_up_timeout)

func _on_times_up_timeout() -> void:
	is_time_frozen = false
	if player:
		player.show_message("Time flows again", Color.WHITE)
		
	# Kích hoạt lại cho toàn bộ quái hoạt động bình thường
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is CharacterBody2D:
			enemy.set_physics_process(true) # Bật lại di chuyển
			if enemy.has_node("AnimatedSprite2D"):
				enemy.get_node("AnimatedSprite2D").play() # Chạy lại animation
