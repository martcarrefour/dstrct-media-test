extends Node2D
class_name Round

var player_combatants: Array[Combatant] = []
var enemy_combatants: Array[Combatant] = []
var turn_order: Array[Combatant] = []
var current_combatant_index: int = 0
var battle_over: bool = false


func _ready() -> void:
	start_round()


func _input(event: InputEvent) -> void:
	if battle_over:
		return

	if event is InputEventKey and event.pressed:
		var key = OS.get_keycode_string(event.physical_keycode)
		if key.to_int() > 0 and key.to_int() <= enemy_combatants.size():
			var target_index = key.to_int() - 1
			select_target_for_current_combatant(target_index)


func generate_turn_order():
	var all_combatants = player_combatants + enemy_combatants
	for combatant in all_combatants:
		combatant.initiative += randi_range(-3, 3)
	all_combatants.sort_custom(func(a, b): return a.initiative > b.initiative)
	add_noise_to_equal_initiative(all_combatants)
	all_combatants.sort_custom(func(a, b): return a.initiative > b.initiative)

	turn_order = all_combatants


func add_noise_to_equal_initiative(combatants: Array) -> void:
	for i in range(1, combatants.size()):
		if combatants[i].initiative == combatants[i - 1].initiative:
			combatants[i].initiative += randf_range(-0.1, 0.1)
			
			
func start_round() -> void:
	current_combatant_index = 0
	clear_scene_combatants()
	add_combatants_to_scene()
	generate_turn_order()

	print("Turn order for this round:")
	for combatant in turn_order:
		print(combatant.name + " (Initiative: " + str(combatant.initiative) + ")")

	execute_turn()


func clear_scene_combatants() -> void:
	for combatant in player_combatants + enemy_combatants:
		if combatant.get_parent() == self:
			remove_child(combatant)


func add_combatants_to_scene() -> void:
	for combatant in player_combatants + enemy_combatants:
		if combatant.get_parent() == null:
			add_child(combatant)


func execute_turn() -> void:
	if battle_over:
		return

	if current_combatant_index >= turn_order.size():
		check_victory_or_start_next_round()
		return

	var current_combatant = turn_order[current_combatant_index]
	if current_combatant in player_combatants:
		if enemy_combatants.size() > 0:
			display_enemy_targets()
		else:
			process_combatant_status()
	else:
		enemy_ai_attack()


func display_enemy_targets() -> void:
	for i in range(enemy_combatants.size()):
		print(str(i + 1) + ": " + enemy_combatants[i].name + " (HP: " + str(enemy_combatants[i].hp) + ")")


func select_target_for_current_combatant(target_index: int) -> void:
	if target_index >= 0 and target_index < enemy_combatants.size():
		var target = enemy_combatants[target_index]
		var current_combatant = turn_order[current_combatant_index]
		current_combatant.attack(target)
		process_combatant_status()
	else:
		print("Invalid target, please try again.")


func enemy_ai_attack() -> void:
	var current_combatant = turn_order[current_combatant_index]
	if player_combatants.size() > 0:
		var target = player_combatants[randi_range(0, player_combatants.size() - 1)]
		print(current_combatant.name + " attacks " + target.name)
		current_combatant.attack(target)
		# Debug message
		print("Player has " + str(player_combatants.size()) + " combatants left.")
		print("Player combatants' status:")
		for combatant in player_combatants:
			print(combatant.name + " - HP: " + str(combatant.hp))

	process_combatant_status()


func process_combatant_status() -> void:
	remove_dead_combatants()
	if check_victory():
		return
	current_combatant_index += 1
	execute_turn()


func remove_dead_combatants() -> void:
	for combatant in turn_order.duplicate():
		if combatant.hp <= 0:
			turn_order.erase(combatant)
			if combatant in player_combatants:
				player_combatants.erase(combatant)
			else:
				enemy_combatants.erase(combatant)


func check_victory() -> bool:
	if enemy_combatants.size() == 0:
		end_battle("Player")
		return true
	elif player_combatants.size() == 0:
		end_battle("Enemy")
		return true
	return false


func check_victory_or_start_next_round() -> void:
	if not check_victory():
		print("Starting a new round...")
		start_round()


func end_battle(winner: String) -> void:
	print(winner + " has won the battle!")
	battle_over = true
