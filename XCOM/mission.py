import random as r
#from ai import EnemyAI
from map import Map, distance
from units import Unit, initialize_enemy, create_pods
import time
import math

soldiers = [Unit('1 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=True, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=1), Unit('2 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=False, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=0), Unit('3 XCOM SOLDIER', force_level=1, hp=8, mobility=8, aim=80, defense=0, armor=1, will=55, can_use_cover=True, can_attack_twice=False, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=True, faction='XCOM', tier=2)]

class Mission:
    def __init__(self, size, objective, soldiers, factions, force_level, pod_count):
        self.map = Map(size)
        self.objective = objective
        self.soldiers = soldiers
        self.total_enemy_hp = 0
        self.factions = factions
        self.force_level = force_level
        self.pod_count = pod_count

    def deploy_enemies(self):
        self.pods = create_pods(self.pod_count, self.force_level)
        for pod in self.pods:
            while True:
                center_x = r.randint(1, self.map.width-2)
                center_y = r.randint(1, round(2*(self.map.height-1)/3))
                print(center_x, center_y)
                if self.map.grid[center_y][center_x] is None and not self.map.cover[center_y][center_x]:
                    for enemy in pod:
                        if enemy.name == pod[0].name:
                            self.map.grid[center_y][center_x] = enemy
                            enemy.x = center_x
                            enemy.y = center_y
                            self.total_enemy_hp += enemy.hp
                        else:
                            if self.map.grid[center_y][center_x-1] is None:
                                self.map.grid[center_y][center_x-1] = enemy
                                self.map.cover[center_y][center_x-1] = False
                                enemy.x = center_x-1
                                enemy.y = center_y
                                self.total_enemy_hp += enemy.hp
                            elif self.map.grid[center_y][center_x+1] is None:
                                self.map.grid[center_y][center_x+1] = enemy
                                self.map.cover[center_y][center_x+1] = False
                                enemy.x = center_x+1
                                enemy.y = center_y
                                self.total_enemy_hp += enemy.hp
                            elif self.map.grid[center_y-1][center_x] is None:
                                self.map.grid[center_y-1][center_x] = enemy
                                self.map.cover[center_y-1][center_x] = False
                                enemy.x = center_x
                                enemy.y = center_y-1
                                self.total_enemy_hp += enemy.hp
                            elif self.map.grid[center_y+1][center_x] is None:
                                self.map.grid[center_y+1][center_x] = enemy
                                self.map.cover[center_y+1][center_x] = False
                                enemy.x = center_x
                                enemy.y = center_y+1
                                self.total_enemy_hp += enemy.hp
                    break
        self.enemies = [enemy for pod in self.pods for enemy in pod]

    def deploy_soldiers(self):
        for x in range(self.map.width):
            self.map.grid[self.map.height-1][x] = None
            self.map.cover[self.map.height-1][x] = 0
        squad_size = len(self.soldiers)
        start_x = (self.map.width - squad_size) // 2
        for i, soldier in enumerate(self.soldiers):
            target_x = start_x + i
            self.map.grid[self.map.height -1][target_x] = soldier
            soldier.x = target_x
            soldier.y = self.map.height-1

    def in_bounds(self, x, y) -> bool:
        return 0 <= x < self.map.width and 0 <= y < self.map.height

    def cover_at(self, x, y) -> int:
        return self.map.cover[y][x] if self.in_bounds(x, y) else 0
    
    def cover_blocks_los(self, x, y) -> bool:
        return self.cover_at(x, y) > 0

    def line_of_sight(self, soldier, target) -> bool:
        if self.is_in_cover(soldier) and self.is_in_cover(target):
            for i in [-1, 0, 1]:
                for j in [-1, 0, 1]:
                    if distance(soldier.x-j, target.x-j, soldier.y-i, target.y-i) > 10:
                        return False
                    dx = ((target.x-j) - (soldier.x-j))
                    dy = ((target.y-i) - (soldier.y-i))
                    for t in range(11):
                        t = t/10
                        pos = (round(soldier.x-j + t*dx), round(soldier.y-i + t*dy))
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_blocks_los(pos[0], pos[1]):
                            return False
        elif self.is_in_cover(soldier):
            for i in [-1, 0, 1]:
                for j in [-1, 0, 1]:
                    if distance(soldier.x-j, target.x, soldier.y-i, target.y) > 10:
                        return False
                    dx = ((target.x) - (soldier.x-j))
                    dy = ((target.y) - (soldier.y-i))
                    for t in range(11):
                        t = t/10
                        pos = (round(soldier.x-j + t*dx), round(soldier.y-i + t*dy))
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_blocks_los(pos[0], pos[1]):
                            return False
        elif self.is_in_cover(target):
            for i in [-1, 0, 1]:
                for j in [-1, 0, 1]:
                    if distance(soldier.x, target.x-j, soldier.y, target.y-i) > 10:
                        return False
                    dx = ((target.x-j) - (soldier.x))
                    dy = ((target.y-i) - (soldier.y))
                    for t in range(11):
                        t = t/10
                        pos = (round(soldier.x + t*dx), round(soldier.y + t*dy))
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_blocks_los(pos[0], pos[1]):
                            return False
        else:
            if distance(soldier.x, target.x, soldier.y, target.y) > 10:
                return False
            dx = (target.x - soldier.x)
            dy = (target.y - soldier.y)
            for t in range(11):
                t = t/10
                pos = (round(soldier.x + t*dx), round(soldier.y + t*dy))
                if not self.in_bounds(pos[0], pos[1]) or self.cover_blocks_los(pos[0], pos[1]):
                    return False
        return True
    
    def is_in_cover(self, soldier) -> bool:
        return (
            self.cover_at(soldier.x, soldier.y-1) or
            self.cover_at(soldier.x, soldier.y+1) or
            self.cover_at(soldier.x-1, soldier.y) or
            self.cover_at(soldier.x+1, soldier.y)
        )
    
    def is_covered_from_unit(self, soldier, unit) -> bool:
        #If the soldier is covered from the unit
        if not self.is_in_cover(soldier):
            return False
        if not soldier.can_use_cover:
            return False
        dx = unit.x - soldier.x
        dy = unit.y - soldier.y

        if math.fabs(dx) > math.fabs(dy):
            if dx < 0:
                return self.cover_at(soldier.x-1, soldier.y)
            else:
                return self.cover_at(soldier.x+1, soldier.y)
        else:
            if dy < 0:
                return self.cover_at(soldier.x, soldier.y-1)
            else:
                return self.cover_at(soldier.x, soldier.y+1)
    
    def targets(self, soldier) -> dict:
        targets = {}
        if soldier.faction == 'XCOM':
            for pod in self.pods:
                for enemy in pod:
                    if self.line_of_sight(soldier, enemy) and enemy.hp>0:
                        hit_chance = soldier.aim - enemy.defense
                        hit_chance -= 20 if self.is_covered_from_unit(enemy, soldier) else 0
                        targets[enemy] = hit_chance
        elif soldier.faction == 'ADVENT':
            for s in self.soldiers:
                if self.line_of_sight(soldier, s) and s.hp > 0:
                    hit_chance = soldier.aim - s.defense
                    hit_chance -= 20 if self.is_covered_from_unit(s, soldier) else 0
                    targets[s] = hit_chance
        return targets
    
    def process_targets(self, targets):
        unprocessed = [key for key in targets.keys()]
        processed_list = sorted(unprocessed, key=lambda x: targets[x], reverse=True)
        for i, target in enumerate(processed_list, start=1):
            print(f"{i}: {target.name} ({targets[target]}% to hit)")
        return processed_list

    def refresh_map(self):
        self.total_enemy_hp = 0
        for pod in self.pods:
            for enemy in pod:
                self.total_enemy_hp += enemy.hp
        self.map.display()
        print(self.total_enemy_hp)

    def XCOM_turn(self):
        for s in self.soldiers:
            self.refresh_map()
            s.overwatch = False
            print(f"{s.name}'s turn")
            ap_used = 0
            while ap_used < s.ap:
                action = input("A: Attack, M: Move, O: Overwatch: ").upper()
                if action == 'A':
                    targets = self.targets(s)
                    if targets:
                        processed_targets, target_list = self.process_targets(targets)
                        try:
                            target = int(input("Select target: "))
                        except TypeError:
                            print("Invalid Target.")
                            continue
                        s.primary_attack(target_list[target-1])
                        if s.can_attack_twice:
                            ap_used += 1
                        else:
                            ap_used = s.ap
                    else:
                        print("No targets for", s.name)
                elif action == 'M':
                    try:
                        print("Current position: (", s.x, ",", s.y, ")")
                        new_x = int(input("Enter new x coordinate: "))
                        new_y = int(input("Enter new y coordinate: "))
                    except TypeError:
                        print("Invalid coordinates.")
                        continue
                    if self.map.move_unit(s, new_x, new_y):
                        print(f"{s.name} moved to ({new_x}, {new_y})")
                        ap_used += 1
                        self.check_overwatch(s)
                        self.check_los(s)
                    else:
                        print(f"Invalid move for {s.name}.")
                elif action == 'O':
                    print(f"{s.name} is on overwatch.")
                    s.overwatch = True
                    ap_used = s.ap

    def check_overwatch(self, soldier):
        if soldier.faction == 'XCOM':
            for pod in self.pods:
                for enemy in pod:
                    if self.line_of_sight(enemy, soldier) and enemy.overwatch:
                        print(f"{enemy.name} takes an overwatch shot at {soldier.name}!")
                        enemy.primary_attack(soldier)
        elif soldier.faction == 'ADVENT':
            for s in self.soldiers:
                if self.line_of_sight(soldier, s) and s.overwatch:
                    print(f"{soldier.name} takes an overwatch shot at {s.name}!")
                    soldier.primary_attack(s)

    def check_los(self, soldier):
        for pod in self.pods:
            for e in pod:
                if self.line_of_sight(soldier, e):
                    if not e.ai.state == 'ACTIVE':
                        e.ai.scatter(e)

    def ADVENT_turn(self):
        pass


def build_move_map(unit, map):
    move_map = []
    for y in range(map.height):
        for x in range(map.width):
            if distance(unit.x, x, unit.y, y) <= unit.mobility and map.cover[y][x] == 0:
                move_map.append((x, y))
    return move_map

class EnemyAI:
    def __init__(self, mission):
        self.mission = mission
        self.player_units = mission.soldiers
        self.state = 'PATROL'  # Initial state

    def patrol(self, enemy):
        # Simple patrol logic: move randomly within a certain range
        move_map = build_move_map(enemy, self.mission.map)
        if move_map:
            new_position = r.choice(move_map)
            self.mission.map.move_unit(enemy, new_position[0], new_position[1])
            print(f"{enemy.name} is patrolling to {new_position}")

    def active(self, enemy):
        ap_used = 0
        while enemy.ap > ap_used:
                best_move, score = self.evaluate_moves(enemy, self.player_units)
                print(f"{enemy.name} evaluated best move to {best_move} with score {score}")
                if best_move:
                    self.mission.map.move_unit(enemy, best_move[0], best_move[1])
                    ap_used += 1  #Blue move costs 1 AP   
                    print(f"{enemy.name} moved to {best_move}")
                    targets = self.mission.targets(enemy)
                    target_list = [key for key in targets.keys()]
                    if targets:
                        enemy.primary_attack(sorted(target_list, key=lambda x: targets[x])[0])
                        if enemy.can_attack_twice:
                            ap_used +=1
                        else:
                            ap_used = enemy.ap
                    else:
                        continue #through loop again to move if no targets

    def take_turn(self, enemy):
            if enemy.state == 'PATROL':
                self.patrol(enemy)
                # Transition to ACTIVE state if a player unit is detected
                for player in self.player_units:
                    if self.mission.line_of_sight(enemy, player):
                        print(f"{enemy.name} has detected {player.name} and is now active!")
                        self.scatter(enemy)
                        break
            elif enemy.state == 'ACTIVE':
                self.active(enemy)

    def scatter(self, enemy):
        best_scatter_move, best_scatter_score = self.evaluate_moves(enemy, self.player_units)
        if best_scatter_move:
            self.mission.map.move_unit(enemy, best_scatter_move[0], best_scatter_move[1])
            print(f"{enemy.name} scattered to {best_scatter_move} with score {best_scatter_score}")
            enemy.state = 'ACTIVE'  # Transition to ACTIVE state after scattering

                      

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

        return best_move, score
    
    def evaluate_position(self, position, enemy, player_units):
        score = 0
        for p in player_units:
            #If not in line of sight, award nothing.
            if not self.mission.line_of_sight(enemy, p):
                score -= 5  # Penalize for moving out of line of sight
            #If the enemy is flanked, award nothing
            if not self.mission.is_covered_from_unit(enemy, p):
                score -= 10  # Penalize for being flanked
            #If the player is flanked, award points
            if not self.mission.is_covered_from_unit(p, enemy):
                score += 30
            #Reward moving closer to the player unit
            score += (enemy.primary_weapon.range - distance(enemy.x, p.x, enemy.y, p.y)) * 2
            #If moving into high cover, award points
            score += self.mission.map.cover[position[1]][position[0]] * 5
        return score

if __name__ == "__main__":
    mission = Mission('small', 'protect device', soldiers=soldiers, factions=['XCOM', 'ADVENT'], force_level=12, pod_count=3)
    mission.map.display()
    mission.deploy_soldiers()
    mission.deploy_enemies()
    mission.map.display()

    while mission.total_enemy_hp > 0:
        print(mission.total_enemy_hp)
        mission.XCOM_turn()
        mission.ADVENT_turn()