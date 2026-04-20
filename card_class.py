import requests
import os
import streamlit as st
from card_app import stripCard

deck=[]
removed=[]
added=[]
menu=""
lists=[]

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
            with open(f'{path}/{cmdr_name}/{stripCard(cmdr_name)}_decklist.txt', 'a') as f:
                f.write(f'{self.name}\n')
                print(f'Added {self.name} to {cmdr_name} decklist.')
                st.write(f'Added {self.name} to {cmdr_name} decklist.')
        except Exception as e:
            print(f"An error occurred while adding {self.name} to decklist: {e}")
            st.error(f"An error occurred while adding {self.name} to decklist: {e}")
    
    def remove_from_decklist(self, cmdr_name):
        try:
            cmdr_name = stripCard(cmdr_name)
            deck_path = f'{path}/{cmdr_name}/{stripCard(cmdr_name)}_decklist.txt'
            with open(deck_path, 'r') as f:
                lines = f.readlines()

            filtered = []
            for line in lines:
                card_name = stripCard(line.strip())
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

menu = st.selectbox("Select an option", options=['Please Select an Option', 'Add Cards', 'Remove Cards', 'View Decklists', 'Quit'], key='menu', placeholder="Please Select an Option")
if __name__ == "__main__":
        if menu == 'Please Select an Option':
            pass

        elif menu == 'Add Cards':
            st.selectbox("Enter by file or text input", options=['File Upload', 'Text Input'], key='add_input_method', placeholder="Enter by file or text input")
            if st.session_state.add_input_method == 'Text Input':
                cmdr_name = st.text_input("Enter the name of the commander: ", key='add_cmdr_name_input')
                new_cards=st.text_area("Enter card names (one per line): ", key='add_text_area')
                if cmdr_name and new_cards:
                    card_names = [line.strip() for line in new_cards.splitlines()]
                    for card_name in card_names:
                        card = Card(card_name)
                        card.add_to_decklist(cmdr_name)
            elif st.session_state.add_input_method == 'File Upload':
                added=st.file_uploader("Enter text file of cards to add: ", key='add_file_uploader')
                cmdr_name = st.text_input("Enter the name of the commander: ", key='add_cmdr_name_input')
                if added is not None:
                    content = added.getvalue().decode('utf-8')
                    card_names = [line.strip() for line in content.splitlines()]
                    for card_name in card_names:
                        card = Card(card_name)
                        card.add_to_decklist(cmdr_name)

        elif menu == 'Remove Cards':
            st.selectbox("Enter by file or text input", options=['File Upload', 'Text Input'], key='remove_input_method', placeholder="Enter by file or text input")
            if st.session_state.remove_input_method == 'Text Input':
                cmdr_name = st.text_input("Enter the name of the commander: ", key='remove_cmdr_name_input')
                new_cards=st.text_area("Enter card names (one per line): ", key='remove_text_area')
                if cmdr_name and new_cards:
                    card_names = [line.strip() for line in new_cards.splitlines()]
                    for card_name in card_names:
                        card = Card(card_name)
                        card.remove_from_decklist(cmdr_name)
            elif st.session_state.remove_input_method == 'File Upload':
                removed=st.file_uploader("Enter text file of cards to remove: ", key='remove_file_uploader')
                cmdr_name = st.text_input("Enter the name of the commander: ", key='remove_cmdr_name_input')
                if removed is not None:
                    content = removed.getvalue().decode('utf-8')
                    card_names = [line.strip() for line in content.splitlines()]
                    for card_name in card_names:
                        card = Card(card_name)
                        card.remove_from_decklist(cmdr_name)

        elif menu == 'View Decklists':
            lists = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
            cmdr_name = st.selectbox("Select a commander:", options=lists)
            if cmdr_name:
                deck_path = f'{path}/{cmdr_name}/{stripCard(cmdr_name)}_decklist.txt'
                if os.path.exists(deck_path):
                    with open(deck_path, 'r') as f:
                        decklist = f.read()
                        if decklist.strip() == "":
                            st.info(f"{cmdr_name}'s decklist is currently empty.")
                        else:
                            st.text_area(f"{cmdr_name}'s Decklist", value=decklist, height=300)
                else:
                    st.error(f"No decklist found for {cmdr_name}.")

        elif menu == 'Quit':
            print("Exiting program.")
            st.write("Exiting program.")
        else:
            print("Invalid option. Please try again.")



