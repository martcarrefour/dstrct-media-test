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

func generate_turn_order() -> void:
	print("Generating turn order...")
	var all_combatants = player_combatants + enemy_combatants

	all_combatants.shuffle()
	all_combatants.sort_custom(_sort_by_initiative)

	turn_order = all_combatants
	print("Turn order: " + ", ".join(turn_order.map(func(combatant): return combatant.name)))

func _sort_by_initiative(a: Combatant, b: Combatant) -> bool:
	return a.initiative > b.initiative

func start_round() -> void:
	print("====== Round Start ======")
	current_combatant_index = 0
	generate_turn_order()
	execute_turn()

func execute_turn() -> void:
	if current_combatant_index >= turn_order.size():
		print("====== Round Complete ======")
		check_victory_or_start_next_round()
		return

	var current_combatant = turn_order[current_combatant_index]
	print("Turn: " + current_combatant.name)
	if current_combatant in player_combatants:
		if enemy_combatants.size() > 0:
			print("Choose a target to attack:")
			display_enemy_targets()
		else:
			print("No enemies remaining.")
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
	else:
		print(current_combatant.name + " has no valid targets to attack.")
	process_combatant_status()

func process_combatant_status() -> void:
	remove_dead_combatants()
	display_combatants_hp()
	if check_victory():
		return
	current_combatant_index += 1
	execute_turn()

func remove_dead_combatants() -> void:
	for combatant in turn_order.duplicate():
		if combatant.hp <= 0:
			print(combatant.name + " was killed!")
			turn_order.erase(combatant)
			if combatant in player_combatants:
				player_combatants.erase(combatant)
			else:
				enemy_combatants.erase(combatant)

func check_victory() -> bool:
	if enemy_combatants.size() == 0:
		print("Player has won the battle!")
		end_battle()
		return true
	elif player_combatants.size() == 0:
		print("Enemy has won the battle!")
		end_battle()
		return true
	return false

func check_victory_or_start_next_round() -> void:
	if not check_victory():
		print("Starting a new round...")
		start_round()

func display_combatants_hp() -> void:
	print("=== Current HP of All Combatants ===")
	for combatant in player_combatants:
		print(combatant.name + ": " + str(combatant.hp) + " HP")
	for combatant in enemy_combatants:
		print(combatant.name + ": " + str(combatant.hp) + " HP")
	print("===")

func end_battle() -> void:
	print("The battle is over.")
	battle_over = true  
