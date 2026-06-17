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

    def damage(self):
        return r.randint(self.damage_range[0], self.damage_range[1])


class XCOMWeapon:
    pass

class LOSTWeapon:
    pass

class CHOSENWeapon:
    pass