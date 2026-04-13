import requests
import os
from card_app import stripCard

cards=["Sawtooth Thresher", "Solarion", "Cryptic Trilobyte", "Astarion's Thirst",
       "Gwenna, Eyes of Gaea", "Shaman of Forgotten Ways", "Bristly Bill, Spine Sower"]

path = "/workspaces/CardStuffs/decks"
class Card:
    def __init__(self, name):
        self.name = name
        self.stripped_name = stripCard(name)
        self.image_url = self.get_image_url()
        self.is_class = True
        self.amount = 1
        if self.name.strip().lower() in ['forest', 'plains', 'mountain', 'swamp', 'island']:
            self.is_basic_land = True
        else:
            self.is_basic_land = False

    def get_image_url(self):
        try:
            response = requests.get(f"https://api.scryfall.com/cards/named?exact={self.stripped_name}")
            if response.status_code == 200:
                data = response.json()
                return data['image_uris']['normal']
            else:
                return None
        except Exception as e:
            print(f"An error occurred while fetching image URL for {self.name}: {e}")
            return None
    def add_to_decklist(self, cmdr_name):
        try:
            cmdr_name = stripCard(cmdr_name)
            os.makedirs(f'{path}/{cmdr_name}', exist_ok=True)
            with open(f'{path}/{cmdr_name}/{cmdr_name}_decklist.txt', 'a') as f:
                f.write(f'1, {self.name}\n')
                print(f'Added {self.name} to {cmdr_name} decklist.')
        except Exception as e:
            print(f"An error occurred while adding {self.name} to decklist: {e}")
        


class BasicLand(Card):
    def __init__(self, name):
        super().__init__(name)
        self.is_basic_land = True




for card in cards:
    if card.strip().lower() in ['forest', 'plains', 'mountain', 'swamp', 'island']:
        card_instance = BasicLand(card)
    else:
        card_instance = Card(card)
    print(f"Card Name: {card_instance.name}, Image URL: {card_instance.image_url}")
    card_instance.add_to_decklist("Example Commander")
