extends Node

# 📌 Signal émis quand une entité prend des dégâts
signal entity_damaged(entity, new_health)
signal entity_died(entity)

@export var damage_cooldown: float = 1.5  # Cooldown global entre chaque prise de dégâts

var damage_timers = {}  # Stocke les cooldowns pour chaque entité

func apply_damage(entity, damage):
	if entity in damage_timers and damage_timers[entity].time_left > 0:
		#print("⏳", entity.name, "est encore en cooldown, pas de dégâts appliqués.")
		return  # L'entité est en cooldown de dégâts

	if entity.has_method("take_damage"):
		entity.take_damage(damage)
		emit_signal("entity_damaged", entity, entity.current_health)

		if entity.current_health <= 0:
			emit_signal("entity_died", entity)
		
		# 📌 Ajoute un cooldown pour éviter le spam de dégâts
		var timer = Timer.new()
		timer.wait_time = damage_cooldown
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_reset_damage_cooldown").bind(entity))
		add_child(timer)
		damage_timers[entity] = timer
		timer.start()
		#print("⏳ Cooldown activé pour", entity.name)

func _reset_damage_cooldown(entity):
	if entity in damage_timers:
		#print("🔄", entity.name, "peut à nouveau prendre des dégâts.")
		damage_timers.erase(entity)
