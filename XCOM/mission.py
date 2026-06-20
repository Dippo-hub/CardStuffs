import random as r
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

    def deploy_soldiers(self):
        for x in range(self.map.width):
            self.map.grid[self.map.height-1][x] = None
            self.map.cover[self.map.height-1][x] = False
        squad_size = len(self.soldiers)
        start_x = (self.map.width - squad_size) // 2
        for i, soldier in enumerate(self.soldiers):
            target_x = start_x + i
            self.map.grid[self.map.height -1][target_x] = soldier
            soldier.x = target_x
            soldier.y = self.map.height-1

    def in_bounds(self, x, y) -> bool:
        return 0 <= x < self.map.width and 0 <= y < self.map.height

    def cover_at(self, x, y) -> bool:
        return self.map.cover[y][x] if self.in_bounds(x, y) else False

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
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_at(pos[0], pos[1]):
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
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_at(pos[0], pos[1]):
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
                        if not self.in_bounds(pos[0], pos[1]) or self.cover_at(pos[0], pos[1]):
                            return False
        else:
            if distance(soldier.x, target.x, soldier.y, target.y) > 10:
                return False
            dx = (target.x - soldier.x)
            dy = (target.y - soldier.y)
            for t in range(11):
                t = t/10
                pos = (round(soldier.x + t*dx), round(soldier.y + t*dy))
                if not self.in_bounds(pos[0], pos[1]) or self.cover_at(pos[0], pos[1]):
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
        for pod in self.pods:
            for enemy in pod:
                if self.line_of_sight(soldier, enemy):
                    hit_chance = soldier.aim - enemy.defense
                    hit_chance -= 20 if self.is_covered_from_unit(enemy, soldier) else 0
                    targets[enemy] = hit_chance
        return targets
    
    def process_targets(self, targets):
        i=1
        for e, value in targets.items():
            print(f'{i}: {e.name}: {value}')
            i += 1
    
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
            print(f"{s.name}'s turn")
            ap_used = 0
            while ap_used < s.ap:
                action = input("A: Attack, M: Move, O: Overwatch: ").upper()
                if action == 'A':
                    targets = self.targets(s)
                    if targets:
                        self.process_targets(targets)
                        target_list = [key for key in targets.keys()]
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

if __name__ == "__main__":
    mission = Mission('small', 'protect device', soldiers=soldiers, factions=['XCOM', 'ADVENT'], force_level=12, pod_count=3)
    mission.map.display()
    mission.deploy_soldiers()
    mission.deploy_enemies()
    mission.map.display()

    while mission.total_enemy_hp > 0:
        print(mission.total_enemy_hp)
        mission.XCOM_turn()