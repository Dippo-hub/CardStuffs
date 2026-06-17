import random as r
#from weapons import ADVENTWeapon, XCOMWeapon, CHOSENWeapon, LOSTWeapon

enemy_info = {
    #'Enemy_name: [force_level 0, hp 1, mobility 2, aim 3, defense 4, will 5, can_use_cover 6, can_attack_twice 7 , primary_weapon 8, secondary_weapon 9, action_points 10, leader 11]
    'Trooper' : [1, 3, 5, 65, 0, 50, True, False, 'ADVENT_rifle', None, 2, False],
    'Captain': [2, 6, 6, 70, 0, 50, True, False, 'ADVENT_rifle', None, 2, True],
    'Sectoid': [2, 8, 6, 65, 0, 80, True, False, 'sectoid_beam', None, 2, True],
    'Stun_Lancer': [3, 5, 8, 55, 0, 50, True, False, 'ADVENT_rifle', 'stun_baton', 2, False],
    'Priest': [4, 5, 5, 60, 0, 80, True, False, 'ADVENT_rifle', None, 2, False],
    'Purifier': [4, 5, 5, 40, 0, 50, True, False, 'ADVENT_flamethrower', None, 2, False],
    'Viper': [5, 8, 8, 70, 0, 60, True, False, 'ADVENT_beam_rifle', None, 2, True],
    'Muton': [6, 10, 6, 70, 5, 60, True, False, 'muton_beam', 'muton_bayonet', 2, True],
    'Codex': [7, 12, 7, 65, 0, 90, True, False, 'ADVENT_beam_rifle', None, 2, False],
    'Berserker': [7, 18, 10, 60, 0, 60, False, False, 'berserker_punch', None, 2, True],
    'Shieldbearer': [8, 8, 6, 65, 10, 60, True, False, 'ADVENT_rifle', None, 2, False],
    'Spectre': [8, 14, 6, 65, 0, 0, True, False, 'ADVENT_beam_rifle', None, 3, True],
    'Chryssalid': [12, 9, 10, 70, 5, 90, False, False, 'pincer', None, 2, True],
    'Archon': [11, 18, 8, 70, 20, 90, False, False, 'archon_staff', 'archon_melee', 3, True],
    'Andromedon': [14, 18, 6, 70, 10, 100, True, False, 'andromedon_beam', 'andromedon_punch', 2, True],
    'Sectopod': [16, 28, 8, 80, 15, 0, False, True, 'sectopod_cannon', 'wrath_cannon', 3, True],
    'Gatekeeper': [18, 30, 9, 80, 25, 150, False, False, 'gatekeeper_beam', None, 3, True],
    'Avatar': [20, 35, 11, 85, 10, 200, True, False, 'psionic_rifle', 'psi_amp', 3, True]
}

ADVENT_weapons = ['stun_baton', 'andromedon_punch', 'wrath_cannon', 'psionic_rifle', 'ADVENT_beam_rifle', 'ADVENT_flamethrower', 'archon_staff', 'andromedon_beam', 'archon_melee', 'pincer', 'muton_beam', 'sectoid_beam', 'gatekeeper_beam', 'sectopod_cannon', 'psi_amp', 'ADVENT_rifle', 'berserker_punch', 'muton_bayonet']

class Unit:
    def __init__(self, force_level, hp, mobility, aim, defense, will, can_use_cover, can_attack_twice, primary_weapon, secondary_weapon, action_points, leader, faction):
        self.force_level = force_level
        self.hp = hp
        self.mobility = mobility
        self.aim = aim
        self.defense = defense
        self.will = will
        self.can_use_cover = can_use_cover
        self.can_attack_twice = can_attack_twice
        self.primary_weapon = primary_weapon
        self.secondary_weapon = secondary_weapon
        self.ap = action_points
        self.is_leader = leader
        self.faction = faction
        self.x = None
        self.y = None

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
            damage = self.primary_weapon.damage - target.armor
            if hit_roll < 15:
                print("Critical hit!")
                damage += 2
            target.hp -= damage
            print(f'{target.name} takes {damage} damage.')
