extends Node

# 📌 Définition des états du jeu
enum GameState { EN_COURS, GAME_OVER, VICTOIRE }

# 📌 Signal pour informer d’un changement d’état
signal game_state_changed(state)
signal timer_updated(time_left)

# 📌 Variables principales
var state : GameState = GameState.EN_COURS
@export var timer : float = 60.0  # Durée de la partie en secondes

func _ready():
	start_game()

# 📌 Démarrer une partie
func start_game():
	state = GameState.EN_COURS
	timer = 60.0  # On remet le timer à 60s
	emit_signal("game_state_changed", state)

# 📌 Mettre à jour le jeu à chaque frame
func _process(delta):
	if state == GameState.EN_COURS:
		timer -= delta
		emit_signal("timer_updated", timer)

		if timer <= 0:
			win_game()

# 📌 Quand le joueur meurt
func game_over():
	if state != GameState.EN_COURS:
		return  # Évite de relancer un Game Over si c'est déjà fait

	state = GameState.GAME_OVER
	emit_signal("game_state_changed", state)

# 📌 Si le joueur survit jusqu’à la fin
func win_game():
	state = GameState.VICTOIRE
	emit_signal("game_state_changed", state)
