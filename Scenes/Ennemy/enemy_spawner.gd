extends Node2D

@export var enemy_scene: PackedScene  # Scène de l'ennemi à spawn
@export var spawn_interval: float = 2.0  # Temps entre chaque spawn
@export var max_enemies: int = 10  # Nombre maximum d'ennemis en même temps
@export var spawn_radius: float = 400.0  # Rayon autour du joueur où les ennemis spawnent

var game_manager
var spawn_timer: Timer

func _ready():
	game_manager = get_node("/root/GameManager")
	game_manager.connect("game_state_changed", Callable(self, "_on_game_state_changed"))

	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_spawn_enemy"))
	add_child(spawn_timer)
	
	var difficulty_timer = Timer.new()
	difficulty_timer.wait_time = 10.0
	difficulty_timer.autostart = true
	difficulty_timer.one_shot = false
	difficulty_timer.connect("timeout", Callable(self, "_increase_difficulty"))
	add_child(difficulty_timer)

func _spawn_enemy():
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return  # Empêche le spawn si trop d'ennemis sont présents

	var enemy = enemy_scene.instantiate()
	enemy.global_position = _get_spawn_position()
	get_tree().current_scene.add_child(enemy)
	#print("👾 Ennemi spawné à :", enemy.global_position)

func _get_spawn_position():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return global_position  # Si aucun joueur, spawn au centre
	
	var player = players[0]  # Récupère le premier joueur trouvé
	
	var angle = randf() * TAU  # Angle aléatoire (entre 0 et 360°)
	var distance = randf_range(spawn_radius * 0.5, spawn_radius)  # Distance aléatoire entre 50% et 100% du rayon
	var offset = Vector2(cos(angle), sin(angle)) * distance  # Crée un décalage aléatoire
	
	return player.global_position + offset  # Position finale autour du joueur


func _on_game_state_changed(state):
	if state == GameManager.GameState.GAME_OVER:
		spawn_timer.stop()
		print("❌ Spawn stoppé : Game Over")

func _increase_difficulty():
	if spawn_interval > 0.5:
		spawn_interval -= 0.1  # Réduit le temps entre les spawns
		spawn_timer.wait_time = spawn_interval
	max_enemies += 2  # Augmente le nombre max d'ennemis
