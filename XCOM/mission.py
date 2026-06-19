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
                center_x = r.randint(0, self.map.width-1)
                center_y = r.randint(0, round(2*(self.map.height-1)/3))
                print(center_x, center_y)
                if self.map.grid[center_y][center_x] is None and not self.map.cover[center_y][center_x]:
                    for enemy in pod:
                        if enemy.name == pod[0].name:
                            self.map.grid[center_y][center_x] = enemy
                            enemy.x = center_x
                            enemy.y = center_y
                        else:
                            if self.map.grid[center_y][center_x-1] is None:
                                self.map.grid[center_y][center_x-1] = enemy
                                self.map.cover[center_y][center_x-1] = False
                                enemy.x = center_x-1
                                enemy.y = center_y
                            elif self.map.grid[center_y][center_x+1] is None:
                                self.map.grid[center_y][center_x+1] = enemy
                                self.map.cover[center_y][center_x+1] = False
                                enemy.x = center_x+1
                                enemy.y = center_y
                            elif self.map.grid[center_y-1][center_x] is None:
                                self.map.grid[center_y-1][center_x] = enemy
                                self.map.cover[center_y-1][center_x] = False
                                enemy.x = center_x
                                enemy.y = center_y-1
                            elif self.map.grid[center_y+1][center_x] is None:
                                self.map.grid[center_y+1][center_x] = enemy
                                self.map.cover[center_y+1][center_x] = False
                                enemy.x = center_x
                                enemy.y = center_y+1
                    break
    def deploy_soldiers(self):
        for x in range(self.map.width):
            self.map.grid[self.map.height-1][x] = None
            self.map.cover[self.map.height-1][x] = False
        squad_size = len(self.soldiers)
        start_x = (self.map.width - squad_size) // 2
        for i, soldier in enumerate(self.soldiers):
            target_x = start_x + i
            self.map.grid[self.map.height -1 ][target_x] = soldier
            soldier.x = target_x
            soldier.y = self.map.height-1

    def line_of_sight(self, soldier, target):
        if distance(soldier.x, target.x, soldier.y, target.y) > 10:
            return False
        dx = (target.x - soldier.x)
        dy = (target.y - soldier.y)
        for t in range(11):
            t=t/10
            pos = (round(soldier.x + t*dx), round(soldier.y + t*dy))
            print(pos)
            if self.map.cover[pos[1]][pos[0]]:
                return False
        return True

if __name__ == "__main__":
    mission = Mission('small', 'protect device', soldiers=soldiers, factions=['XCOM', 'ADVENT'], force_level=12, pod_count=3)
    mission.map.display()
    mission.deploy_soldiers()
    mission.deploy_enemies()
    mission.map.display()

    while len(mission.pods) > 0:
        time.sleep(1)
        for soldier in mission.soldiers:
            if mission.line_of_sight(soldier, mission.pods[0][0]):
                soldier.primary_attack(mission.pods[0][0])
            else:
                print(f'{soldier.name} has no targets!')
            if mission.pods[0][0].hp <= 0:
                mission.pods[0].remove(mission.pods[0][0])
            if len(mission.pods[0]) == 0:
                mission.pods.remove(mission.pods[0])
            time.sleep(1)
        print(" ")
        for pod in mission.pods:
            for enemy in pod:
                if mission.line_of_sight(enemy, mission.soldiers[0]):
                    enemy.primary_attack(mission.soldiers[0])
                else:
                    print(f'{enemy.name} has no targets!')
                if mission.soldiers[0].hp <- 0:
                    mission.soldiers.remove(mission.soldiers[0])
                time.sleep(1)
        break