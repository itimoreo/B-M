extends CanvasLayer

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var kills_label: Label = $VBoxContainer/KillsLabel
@onready var timer_label: Label = $VBoxContainer/TimerLabel


var kills = 0

func _ready() -> void:
	add_to_group("ui")  # 📌 Ajoute UI au groupe 'ui'
	initialize_ui()
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("player_died", Callable(self, "_on_player_died"))
	
	var game_manager = GameManager
	game_manager.connect("timer_updated", Callable(self, "_update_timer"))

func initialize_ui():
	health_label.text = "❤️ Vie: 100"
	kills_label.text = "☠️ Kills: 0"
	timer_label.text = "⏳ Temps: 60"

func update_health(value):
	health_label.text = "❤️ Vie: %d" % value

func increase_kills():
	kills += 1
	kills_label.text = "☠️ Kills: %d" % kills

func _update_timer(time_left):
	timer_label.text = "⏳ Temps: %.1f" % time_left

func _on_player_died():
	health_label.text = "💀 MORT"
