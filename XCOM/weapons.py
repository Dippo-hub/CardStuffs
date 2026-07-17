import random as r

class ADVENTWeapon:
    weapon_base_damages = {'stun_baton' : [2,4],
                            'andromedon_punch': [7,10],
                            'wrath_cannon': [12,14], 
                            'psionic_rifle': [9,11], 
                            'ADVENT_beam_rifle': [3,5], 
                            'ADVENT_flamethrower': [0, 0], 
                            'archon_staff': [6,9], 
                            'andromedon_beam': [8,10], 
                            'archon_melee': [7,10], 
                            'pincer': [4,6], 
                            'muton_beam': [5, 8], 
                            'sectoid_beam': [3, 5],
                            'gatekeeper_beam': [10, 12], 
                            'sectopod_cannon': [9, 11], 
                            'psi_amp': [0, 0], 
                            'ADVENT_rifle': [3,4], 
                            'berserker_punch':[6,8], 
                            'muton_bayonet': [6, 7]}
    def __init__(self, weapon):
        self.damage_range = (self.weapon_base_damages.get(weapon)[0], self.weapon_base_damages.get(weapon)[1])
        if weapon in ['andromedon_punch', 'berserker_punch', 'archon_melee', 'muton_bayonet', 'stun_baton']:
            self.is_melee = True
            self.range = 1
        elif weapon in ['wrath_cannon', 'psionic_rifle', 'gatekeeper_beam']:
            self.is_melee = False
            self.range = 15
        else:
            self.is_melee = False
            self.range = 10

    def damage(self):
        return r.randint(self.damage_range[0], self.damage_range[1])


class XCOMWeapon:
    weapon_base_damages = {
        'rifle': [3,5],
        'shotgun':  [4,6],
        'cannon': [4,6],
        'sniper': [4,6],
        'sword': [3,5],
        'pistol': [2,3],
        'gremlin': [2,2],
        'grenade_launcher': [0,0]
    }
    def __init__(self, weapon, tier):
        self.damage_range = self.weapon_base_damages.get(weapon)
        self.tier = tier

    def damage(self):
        return r.randint(self.damage_range[0], self.damage_range[1]) + (2 * self.tier)

class LOSTWeapon:
    weapon_base_damages = {
        'basic': [1,2],
        'dasher': [2,3],
        'brute': [4,5]
    }

    def __init__(self, weapon, tier):
        self.damage_range = self.weapon_base_damages.get(weapon)
        self.tier = tier

    def damage(self):
        return r.randint(self.damage_range[0], self.damage_range[1]) + (2 * self.tier)

class CHOSENWeapon:
    weapon_base_damages = {
        'arashi': [2,4],
        'darklance': [3,5],
        'disruptor': [2,4],
        'katana': [3,4],
        'darkclaw': [3,4]
    }

    def __init__(self, weapon, knowledge):
        self.damage_range = self.weapon_base_damages.get(weapon)
        self.knowledge = knowledge

    def damage(self):
        return r.randint(self.damage_range[0], self.damage_range[1]) + (3 * self.knowledge)
    
if __name__ == "__main__":
    Cannon = XCOMWeapon('cannon', 2)
    Brute = LOSTWeapon('brute', 1)
    Arashi = CHOSENWeapon('arashi', 2)

    print(Cannon.damage(), Brute.damage(), Arashi.damage())
