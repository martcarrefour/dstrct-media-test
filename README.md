
# Turn-Based Combat System Documentation

# Important Note

Since this is a test assignment developed in very **controlled** conditions, I acknowledge that many aspects could be more optimized.

For example, in the `generate_unique_combinations` function, the code currently generates a list of all possible combinations. This isn’t strictly necessary and, depending on the requirements of the original game, this could be handled differently.

Similarly, for determining turn order when initiatives are identical, I’ve implemented an approach using noise. Simply adding randomness directly to the sorting algorithm isn’t recommended because it can lead to unstable sorting behavior, where the order of elements can change unpredictably between runs. There are other approaches for handling this situation more elegantly.


## Overview

This project implements a turn-based combat system using the Godot Engine. The system includes player-controlled and AI-controlled combatants, each with unique stats, initiative-based turn order, and a round-based structure. The combat system supports key mechanics such as initiative rolling, turn-based execution, and handling random damage during attacks.

## Project Structure

```plaintext
project_directory/
│
├── addons/                            # Placeholder for future plugins
│
├── entities/
│   └── combatant/
│       ├── combatant.gd               # Script for Combatant class
│       └── combatant.tscn             # Scene for Combatant entity
│
├── scenes/
│   ├── battle/
│   │   ├── battle.gd                  # Script for managing the battle
│   │   └── battle.tscn                # Scene for the battle events
│   └── round/
│       ├── round.gd                   # Script for managing combat rounds
│       └── round.tscn                 # Scene for the combat round
│
├── icon.svg                           # Default project icon
└── README.md                          # Project documentation (this file)
```

## Key Components and Methods

### **Combatant Class (entities/combatant/combatant.gd)**

The `Combatant` class represents an individual combatant in the battle. It handles the stats, actions, and state of a combatant.

#### Properties

- **`hp: int`**  
  The health points of the combatant.

- **`initiative: int`**  
  The initiative value used to determine the combatant's position in the turn order.

- **`combatant_name: String`**  
  The name of the combatant.

#### Methods

- **`_init(initial_hp: int, initial_initiative: int, initial_name: String) -> void`**  
  Initializes the combatant with given stats.

- **`attack(target: Combatant) -> void`**  
  Executes an attack on the specified target, dealing random damage between 1 and 10. The randomness is achieved using Godot’s `randi_range(1, 10)` function.

- **`take_damage(amount: int) -> void`**  
  Reduces the combatant's HP by a given amount. If HP falls to 0 or below, the combatant dies by calling the `die()` method.

- **`die() -> void`**  
  Handles the combatant's death by removing it from the scene using `queue_free()`.

### **Battle Class (scenes/battle/battle.gd)**

The `Battle` class is responsible for setting up the combatants and initializing the round.

#### Properties

- **`MIN_HP: int`**  
  The minimum health points for a combatant.

- **`MAX_HP: int`**  
  The maximum health points for a combatant.

- **`MIN_INITIATIVE: int`**  
  The minimum initiative for a combatant.

- **`MAX_INITIATIVE: int`**  
  The maximum initiative for a combatant.

- **`TOTAL_COMBATANTS: int`**  
  The total number of combatants in the battle.

- **`PLAYER_COUNT: int`**  
  The number of player-controlled combatants.

- **`ENEMY_COUNT: int`**  
  The number of AI-controlled combatants.

- **`player_combatants: Array[Combatant]`**  
  A list of player-controlled combatants.

- **`enemy_combatants: Array[Combatant]`**  
  A list of AI-controlled combatants.

#### Methods

- **`_ready() -> void`**  
  Initializes the combatants and starts the battle.

- **`init_round() -> void`**  
  Instantiates a `Round` scene and sets up the combatants for the round.

- **`init_combatants() -> void`**  
  Generates unique combatant combinations and assigns them to the player and enemy teams.

- **`generate_unique_combinations() -> Array`**  
  Generates unique combinations of HP and initiative values for the combatants. The combinations are shuffled and sliced to select a fixed number of combatants.

- **`create_combatants(combinations: Array, prefix: String) -> Array[Combatant]`**  
  Creates combatants based on the provided combinations and prefix (e.g., "Player" or "Enemy").



### **Round Class (scenes/round/round.gd)**

The `Round` class manages the flow of a combat round, including generating the turn order, handling player inputs, and managing combatant actions.

#### Properties

- **`player_combatants: Array[Combatant]`**  
  A list of player-controlled combatants.

- **`enemy_combatants: Array[Combatant]`**  
  A list of AI-controlled combatants.

- **`turn_order: Array[Combatant]`**  
  The order in which combatants take their turns.

- **`current_combatant_index: int`**  
  Tracks the current turn within the round.

- **`battle_over: bool`**  
  Indicates whether the battle has ended.

#### Methods

- **`_ready() -> void`**  
  Initializes the round and starts the combat sequence.

- **`_input(event: InputEvent) -> void`**  
  Handles player input for selecting a target during a player's turn. The system listens for key presses and checks if the input corresponds to an enemy combatant.

- **`generate_turn_order() -> void`**  
  Generates the turn order based on initiative, adding randomness if initiatives are equal. The initiative is adjusted with a random value using `randi_range(-3, 3)`. The function then sorts combatants based on their initiative and applies a small noise factor if initiatives are identical, using `randf_range(-0.1, 0.1)`.

- **`add_noise_to_equal_initiative(combatants: Array) -> void`**  
  This function handles the scenario where multiple combatants have the same initiative value. When combatants are sorted by initiative and have equal values, it becomes difficult to determine their order. To resolve this, a small random noise (between -0.1 and 0.1) is added to the initiative of combatants with equal values. This ensures a unique order for each combatant even when their base initiative is identical.

- **`start_round() -> void`**  
  Prepares the scene for a new round and executes the first turn.

- **`clear_scene_combatants() -> void`**  
  Removes any existing combatants from the scene before adding new ones for the round.

- **`add_combatants_to_scene() -> void`**  
  Adds player and enemy combatants to the scene.

- **`execute_turn() -> void`**  
  Executes the current turn and moves to the next combatant in the turn order. It checks whether the current combatant is a player or an enemy and executes appropriate actions.

- **`display_enemy_targets() -> void`**  
  Displays the list of enemy combatants for the player to choose a target.

- **`select_target_for_current_combatant(target_index: int) -> void`**  
  Allows the player to select a target for their attack.

- **`enemy_ai_attack() -> void`**  
  Controls the AI logic for selecting and attacking a player combatant. The enemy randomly selects a target from the player’s combatants.

- **`process_combatant_status() -> void`**  
  Checks combatants' status and determines whether to move to the next turn or end the battle.

- **`remove_dead_combatants() -> void`**  
  Removes dead combatants from the turn order and respective teams (player or enemy).

- **`check_victory() -> bool`**  
  Checks if either the player or the enemy has won the battle.

- **`check_victory_or_start_next_round() -> void`**  
  Checks if the battle is over; if not, starts a new round.

- **`end_battle(winner: String) -> void`**  
  Ends the battle and prints the winner’s name.

