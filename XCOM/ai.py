from units import Unit, generate_random_soldier
from mission import Mission
from map import Map, distance
import random as r

soldiers = [Unit('1 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=True, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=1), Unit('2 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=False, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=0), Unit('3 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=False, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=2)]

def build_move_map(unit, map):
    move_map = []
    for y in range(map.height):
        for x in range(map.width):
            if distance(unit.x, x, unit.y, y) <= unit.mobility and map.cover[y][x] == 0:
                move_map.append((x, y))
    return move_map

class EnemyAI:
    def __init__(self, enemies, mission, player_units):
        self.enemies = enemies
        self.mission = mission
        self.player_units = player_units

    def take_turn(self):
        for enemy in self.enemies:
            ap_used = 0
            while enemy.ap > ap_used:
                best_move = self.evaluate_moves(enemy, self.player_units)
                if best_move:
                    self.mission.map.move_unit(enemy, best_move[0], best_move[1])
                    ap_used += 1  #Blue move costs 1 AP   
                    print(f"{enemy.name} moved to {best_move}")
                    targets = self.mission.targets(enemy)
                    targets = self.mission.process_targets(targets)
                    if targets:
                        enemy.primary_attack(targets[1])
                        if enemy.can_attack_twice:
                            ap_used +=1
                        else:
                            ap_used = enemy.ap
                        

    def evaluate_moves(self, enemy, player_units):
        best_move = None
        best_score = float('-inf')
        original_position = (enemy.x, enemy.y)

        for move in build_move_map(enemy, self.mission.map):
            enemy.x, enemy.y = move
            score = self.evaluate_position(move, enemy, player_units)
            if score > best_score:
                best_score = score
                best_move = move
        enemy.x, enemy.y = original_position  # Reset to original position

        return best_move
    
    def evaluate_position(self, position, enemy, player_units):
        score = 0
        for p in player_units:
            #If not in line of sight, award nothing.
            if not self.mission.line_of_sight(enemy, p):
                continue
            #If the enemy is flanked, award nothing
            if not self.mission.is_covered_from_unit(enemy, p):
                continue
            #If the player is flanked, award points
            if not self.mission.is_covered_from_unit(p, enemy):
                score += 10
            #If moving into high cover, award points
            score += self.mission.map.cover[position[1]][position[0]] * 5
        return score

if __name__ == "__main__":
    mission = Mission('small', 'protect device', soldiers=soldiers, factions=['XCOM', 'ADVENT'], force_level=12, pod_count=3)
    mission.map.display()
    mission.deploy_soldiers()
    mission.deploy_enemies()
    mission.map.display()
    enemy_ai = EnemyAI(mission.enemies, mission, soldiers)
    print("Enemy AI taking turn...")
    enemy_ai.take_turn()
   