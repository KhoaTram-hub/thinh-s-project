extends Node2D

@onready var health_sprite: Sprite2D = $Health
@onready var default_width = health_sprite.region_rect.size.x
@onready var default_height = health_sprite.region_rect.size.y

# Biến để lưu máu tối đa (Sẽ được Boss gửi sang là 5000)
var max_hp_limit: float = 100.0 

# HÀM KHỞI TẠO (Bắt buộc Boss phải gọi hàm này lúc đầu)
func init_health(max_hp: int) -> void:
	max_hp_limit = float(max_hp)
	update_health(max_hp) # Đưa thanh máu về đầy 100% ban đầu

func update_health(new_health: int) -> void:
	# Tính toán tỷ lệ dựa trên 5000 thay vì 100
	var percentage = float(new_health) / max_hp_limit
	var new_width = percentage * default_width
	
	# Cập nhật hình ảnh thanh máu
	health_sprite.region_rect = Rect2(0, 0, new_width, default_height)
