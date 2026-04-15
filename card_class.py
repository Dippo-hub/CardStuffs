import requests
import os
import streamlit as st
from card_app import stripCard

deck=[]
removed=[]
added=[]
menu=""

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
                f.write(f'{self.name}\n')
                print(f'Added {self.name} to {cmdr_name} decklist.')
                st.write(f'Added {self.name} to {cmdr_name} decklist.')
        except Exception as e:
            print(f"An error occurred while adding {self.name} to decklist: {e}")
            st.error(f"An error occurred while adding {self.name} to decklist: {e}")
    
    def remove_from_decklist(self, cmdr_name):
        try:
            cmdr_name = stripCard(cmdr_name)
            deck_path = f'{path}/{cmdr_name}/{cmdr_name}_decklist.txt'
            with open(deck_path, 'r') as f:
                lines = f.readlines()

            filtered = []
            for line in lines:
                parts = line.split(',', 1)
                if len(parts) < 2:
                    continue
                card_name = stripCard(parts[1])
                if card_name != self.stripped_name:
                    filtered.append(line)

            with open(deck_path, 'w') as f:
                f.writelines(filtered)

            print(f'Removed {self.name} from {cmdr_name} decklist.')
            st.write(f'Removed {self.name} from {cmdr_name} decklist.')
        except FileNotFoundError:
            print(f'Decklist file not found for {cmdr_name}.')
            st.error(f'Decklist file not found for {cmdr_name}.')
        except Exception as e:
            print(f"An error occurred while removing {self.name}: {e}")
            st.error(f"An error occurred while removing {self.name}: {e}")

class BasicLand(Card):
    def __init__(self, name):
        super().__init__(name)
        self.is_basic_land = True

if __name__ == "__main__":
    while menu!='Q':
        menu = input("Enter 'A' to add a card, 'R' to remove a card, or 'Q' to quit: ").upper()
        if menu == 'A':
            added=input("Enter text file of cards to add: ")
            cmdr_name = input("Enter the name of the commander: ")
            with open(added, 'r') as f:
                card_names = [line.strip() for line in f.readlines()]
            for card_name in card_names:
                card = Card(card_name)
                card.add_to_decklist(cmdr_name)
        elif menu == 'R':
            removed=input("Enter text file of cards to remove: ")
            cmdr_name = input("Enter the name of the commander: ")
            with open(removed, 'r') as f:
                card_names = [line.strip() for line in f.readlines()]
            for card_name in card_names:
                card = Card(card_name)
                card.remove_from_decklist(cmdr_name)
        elif menu == 'Q':
            print("Exiting program.")
        else:
            print("Invalid option. Please try again.")



