import random as r

enemy_info = {
    #'Enemy_name: [force_level, hp, mobility, aim, defense, will, can_use_cover, can_attack_twice, primary_weapon, secondary_weapon, action_points]
    'Trooper' : [1, 3, 5, 65, 0, 50, True, False, 'ADVENT_rifle', None, 2],
    'Captain': [2, 6, 6, 70, 0, 50, True, False, 'ADVENT_rifle', None, 2],
    'Sectoid': [2, 8, 6, 65, 0, 80, True, False, 'sectoid_beam', None, 2],
    'Stun_Lancer': [3, 5, 8, 55, 0, 50, True, False, 'ADVENT_rifle', 'stun_baton', 2],
    'Priest': [4, 5, 5, 60, 0, 80, True, False, 'ADVENT_rifle'],
    'Purifier': 4,
    'Viper': 5,

}