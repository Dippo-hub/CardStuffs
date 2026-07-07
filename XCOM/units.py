import random as r
from weapons import ADVENTWeapon, XCOMWeapon, CHOSENWeapon, LOSTWeapon
from mission import EnemyAI

enemy_info = {
    #'Enemy_name: [force_level 0, hp 1, mobility 2, aim 3, defense 4, armor 5, will 6, can_use_cover 7, can_attack_twice 8 , primary_weapon 9, secondary_weapon 10, action_points 11, leader 12]
    'Trooper' : [1, 3, 5, 65, 0, 0, 50, True, False, 'ADVENT_rifle', None, 2, False],
    'Captain': [2, 6, 6, 70, 0, 0, 50, True, False, 'ADVENT_rifle', None, 2, True],
    'Sectoid': [2, 8, 6, 65, 0, 0, 80, True, False, 'sectoid_beam', None, 2, True],
    'Stun_Lancer': [3, 5, 8, 55, 0, 0, 50, True, False, 'ADVENT_rifle', 'stun_baton', 2, False],
    'Priest': [4, 5, 5, 60, 0, 0, 80, True, False, 'ADVENT_rifle', None, 2, False],
    'Purifier': [4, 5, 5, 40, 0, 1, 50, True, False, 'ADVENT_flamethrower', None, 2, False],
    'Viper': [5, 8, 8, 70, 0, 0, 60, True, False, 'ADVENT_beam_rifle', None, 2, True],
    'Muton': [6, 10, 6, 70, 5, 1, 60, True, False, 'muton_beam', 'muton_bayonet', 2, True],
    'Codex': [7, 12, 7, 65, 0, 0, 90, True, False, 'ADVENT_beam_rifle', None, 2, False],
    'Berserker': [7, 18, 10, 60, 0, 0, 60, False, False, 'berserker_punch', None, 2, True],
    'Shieldbearer': [8, 8, 6, 65, 10, 3, 60, True, False, 'ADVENT_rifle', None, 2, False],
    'Spectre': [8, 14, 6, 65, 0, 0, 0, True, False, 'ADVENT_beam_rifle', None, 3, True],
    'Chryssalid': [12, 9, 10, 70, 5, 1, 90, False, False, 'pincer', None, 2, True],
    'Archon': [11, 18, 8, 70, 20, 0, 90, False, False, 'archon_staff', 'archon_melee', 3, True],
    'Andromedon': [14, 18, 6, 70, 10, 3, 100, True, False, 'andromedon_beam', 'andromedon_punch', 2, True],
    'Sectopod': [16, 28, 8, 80, 15, 5, 0, False, True, 'sectopod_cannon', 'wrath_cannon', 3, True],
    'Gatekeeper': [18, 30, 9, 80, 25, 6, 150, False, False, 'gatekeeper_beam', None, 3, True],
    'Avatar': [20, 35, 11, 85, 10, 4, 200, True, False, 'psionic_rifle', 'psi_amp', 3, True]
}

# 20 common first names from major world powers
first_names = [
    "James", "Olivia",     # USA
    "John", "Emma",        # UK
    "Jean", "Marie",       # France
    "Lucas", "Lina",       # Germany
    "Alexander", "Elena",  # Russia
    "Wei", "Fang",         # China
    "Hiroshi", "Sakura",   # Japan
    "Aarav", "Ananya",     # India
    "Mateo", "Sofia",      # Brazil
    "Liam", "Chloe"        # Canada
]

# 20 common last names from major world powers
last_names = [
    "Smith", "Johnson",    # USA
    "Jones", "Williams",   # UK
    "Martin", "Bernard",   # France
    "Müller", "Schmidt",   # Germany
    "Ivanov", "Smirnov",   # Russia
    "Wang", "Li",          # China
    "Sato", "Suzuki",      # Japan
    "Sharma", "Verma",     # India
    "Silva", "Santos",     # Brazil
    "Tremblay", "Roy"      # Canada
]


def generate_random_soldier(rank, tech_level):
    first_name = r.choice(first_names)
    last_name = r.choice(last_names)
    name = first_name +" "+ last_name
    return Unit(name=name, force_level=rank, hp=3+rank+3*tech_level, mobility=8+rank//2, aim=70+2*rank, defense=0, armor=tech_level, will=55+3*rank, can_use_cover=True, can_attack_twice=False, primary_weapon='rifle', secondary_weapon=None, action_points=2, leader=False, faction='XCOM', tier=tech_level)



def create_pods(pod_count, force_level):
    enemies = enemy_info.keys()
    leaders = [enemy for enemy in enemies if enemy_info.get(enemy)[12]]
    followers = [enemy for enemy in enemies if not enemy_info.get(enemy)[12]]
    #print(f'enemies: {enemies},\n leaders: {leaders},\n followers: {followers}')
    pod_size = round(force_level/pod_count) if round(force_level/pod_count) >2 else 2
    pods = []
    for pod in range(pod_count):
        temp = []
        for x in range(pod_size):
            valid = False
            max_fl = force_level
            while not valid:
                if len(temp) == 0:
                    g = r.randint(0, len(leaders)-1)
                    #print(g)
                    leader = leaders[g]
                    if enemy_info.get(leader)[0] <= max_fl:
                        temp.append(initialize_enemy(leader + f' {str(len(pods))}{str(len(temp))}'))
                        max_fl = enemy_info.get(leader)[0]
                        valid = True
                else:
                    g = r.randint(0, len(followers)-1)
                    #print(g)
                    enemy = followers[g]
                    if enemy_info.get(enemy)[0] <= max_fl:
                        enemy += f' {str(len(pods))}{str(len(temp))}'
                        temp.append(initialize_enemy(enemy))
                        valid = True
        pods.append(temp)
    return pods
                
def initialize_enemy(name, mission=None):
    search_name = name.split(' ')[0]
    return Unit(name=name, force_level=enemy_info.get(search_name)[0], hp=enemy_info.get(search_name)[1], mobility=enemy_info.get(search_name)[2], aim=enemy_info.get(search_name)[3], defense=enemy_info.get(search_name)[4], armor=enemy_info.get(search_name)[5], will=enemy_info.get(search_name)[6], can_use_cover=enemy_info.get(search_name)[7], can_attack_twice=enemy_info.get(search_name)[8], primary_weapon=enemy_info.get(search_name)[9], secondary_weapon=enemy_info.get(search_name)[10], action_points=enemy_info.get(search_name)[11], leader=enemy_info.get(search_name)[12], faction='ADVENT', ai=EnemyAI(mission))

class Unit:
    def __init__(self, name, force_level, hp, mobility, aim, defense, armor, will, can_use_cover, can_attack_twice, primary_weapon, secondary_weapon, action_points, leader, faction, tier=0, abilities=[], ai=None):
        self.name = name
        self.force_level = force_level
        self.hp = hp
        self.mobility = mobility
        self.aim = aim
        self.defense = defense
        self.armor = armor
        self.will = will
        self.can_use_cover = can_use_cover
        self.can_attack_twice = can_attack_twice
        self.overwatch = False
        if faction == 'ADVENT':
            self.primary_weapon = ADVENTWeapon(primary_weapon)
        elif faction == 'XCOM':
            self.primary_weapon = XCOMWeapon(primary_weapon, tier)
        elif faction == 'LOST':
            self.primary_weapon = LOSTWeapon(primary_weapon, tier)
        elif faction == 'CHOSEN':
            self.primary_weapon = CHOSENWeapon(primary_weapon, tier)
        self.secondary_weapon = ADVENTWeapon(secondary_weapon) if secondary_weapon is not None else None
        self.ap = action_points
        self.is_leader = leader
        self.faction = faction
        self.abilities = abilities
        self.x = None
        self.y = None
        if self.faction == 'XCOM':
            self.state = 'CONCEALED'
        else:
            self.state = 'PATROL'

    def move(self, x, y):
        if self.x is None or self.y is None:
            print("Unit is not on the board.")
            return False
        
        while self.x != x and self.y != y:
            if self.x < x:
                self.x+=1
            elif self.x > x:
                self.x -= 1
            if self.y < y:
                self.y+=1
            elif self.y > y:
                self.y-=1
        return True
    
    def primary_attack(self, target):
        hit_chance = self.aim - target.defense
        hit_roll = r.randint(1, 100)
        if hit_roll <= hit_chance:
            print(f"{self.name} attacks {target.name}.")
            damage = self.primary_weapon.damage() - target.armor
            damage = damage if damage > 1 else 1
            if hit_roll < 15:
                print("Critical hit!")
                damage += 2
            target.hp -= damage 
            print(f'{target.name} takes {damage} damage.')
            if target.hp<=0:
                print(f"{target.name} was killed!")
        else:
            print(f"{self.name} misses {target.name} ({hit_chance}% to hit, rolled {100 - hit_roll}).")

    def process_abilities(self):
            for i, a in enumerate(self.abilities, start=1):
                print(f"{i}: {a}")
            selection = input("Select ability to use: ")
            try:
                    selection = int(selection)
                    if 1 <= selection <= len(self.abilities):
                        ability = self.abilities[selection - 1]
                        print(f"{self.name} uses {ability}.")
                        # Implement ability effects here
                    else:
                        print("Invalid selection.")
            except ValueError:
                    print("Invalid input. Please enter a number.")

if __name__ == "__main__":
    soldier = generate_random_soldier(4, 2)
    print(soldier.name)
