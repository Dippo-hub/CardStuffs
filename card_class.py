import requests
import os
import re
import streamlit as st
import bcrypt
from card_app import stripCard
def stripCardForSearch(name):
    trimmed = name.strip()
    if len(trimmed) > 2:
        trimmed = trimmed[2:]
    else:
        trimmed = ""
    while trimmed[0] == " ":
        trimmed = trimmed[1:]
    return trimmed.lower().replace(" ", "-").replace(",", "").replace("'", "").replace(".", "").replace(":", "").replace("!", "").replace("?", "")


deck=[]
removed=[]
added=[]
menu=""
lists=[]

path = "/workspaces/CardStuffs/decks"

# Initialize session state
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False

def hash_password(password):
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed

def goodUser(username):
    with open('users.txt', 'r') as f:
        users = [line.strip() for line in f]
    return username in users

def verify_password(password, username):
    try:
        users = []
        with open('users.txt', 'r') as f:
            users = [line.strip() for line in f]
        
        with open('passwords.txt', 'r') as f:
            passwords = [line.strip() for line in f]
        
        if username not in users:
            return False
        
        user_index = users.index(username)
        stored_hash = passwords[user_index]
        
        # Convert the string representation back to bytes
        stored_hash_bytes = eval(stored_hash)  # Converts b'...' string to bytes
        
        # Use bcrypt to verify
        return bcrypt.checkpw(password.encode('utf-8'), stored_hash_bytes)
    except Exception as e:
        print(f"Error verifying password: {e}")
        return False


class Card:
    def __init__(self, name):
        self.name = name
        self.stripped_name = stripCard(name)
        self.image_search_name = stripCardForSearch(name)
        self.image_url = self.get_image_url()
        if self.name.strip().lower() in ['forest', 'plains', 'mountain', 'swamp', 'island']:
            self.is_basic_land = True
        else:
            self.is_basic_land = False
        self.amount = 1
    def get_image_url(self, face='front'):
        try:
            if face == 'front':
                face = 0
            elif face == 'back':
                face = 1
            response = requests.get(f"https://api.scryfall.com/cards/named?exact={self.image_search_name}")
            if response.status_code == 200:
                data = response.json()
                # Handle double-sided cards
                if 'card_faces' in data:
                    return data['card_faces'][face]['image_uris']['normal']
                else:
                    return self.name
            else:
                return self.name
        except Exception as e:
            print(f"An error occurred while fetching image URL for {self.name}: {e}")
            return None
        
    def add_to_decklist(self, cmdr_name):
        try:
            cmdr_name = stripCard(cmdr_name)
            os.makedirs(f'{path}/{cmdr_name}', exist_ok=True)
            with open(f'{path}/{cmdr_name}/{stripCard(cmdr_name)}_decklist.txt', 'a') as f:
                f.write(f'1, {self.name}\n')
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
    
    def show_image(self):
        if self.image_url:
            st.sidebar.image(self.image_url, caption=self.name)
        else:
            st.sidebar.write(f"No image available for {self.image_search_name}.")

class BasicLand(Card):
    def __init__(self, name):
        super().__init__(name)
        self.is_basic_land = True

class Commander(Card):
    def __init__(self, name):
        super().__init__(name)
        self.is_commander = True
        self.image_search_name = stripCard(name)

# Main app logic
if st.session_state.logged_in:
    james = st.selectbox("Select an option", options=['Please Select an Option', 'Add Cards', 'Remove Cards', 'View Decklists', 'Logout'], key='james', placeholder="Please Select an Option")
    st.sidebar.title("Images here:")
    
    if james == 'Please Select an Option':
        pass

    elif james == 'Add Cards':
        global basics, plains, mountains, swamps, islands, forests, count
        basics = []
        plains = 0
        mountains = 0
        swamps = 0
        islands = 0
        forests = 0
        count=0
        st.selectbox("Enter by file or text input", options=['File Upload', 'Text Input'], key='add_input_method', placeholder="Enter by file or text input")
        if st.session_state.add_input_method == 'Text Input':
            cmdr_name = st.text_input("Enter the name of the commander: ", key='add_cmdr_name_input')
            new_cards=st.text_input("Enter card names (one per line): ", key='add_text_area')
            new_cards = re.split(r'\d+ ', new_cards) 
            if cmdr_name and new_cards:
                card_names = [line.strip() for line in new_cards]
                with st.status(label="Adding cards to decklist...", state="running") as status:
                    for card_name in card_names:
                        if len(card_name) <= 2:
                            continue
                        card = Card(card_name)
                        if card.is_basic_land:
                            basics.append(card.name)
                            count+=1
                            continue
                        count+=1
                        card.add_to_decklist(cmdr_name)
                    if basics:
                        for land in basics:
                            if land.lower() == 'plains':
                                plains += 1
                            elif land.lower() == 'mountain':
                                mountains += 1
                            elif land.lower() == 'swamp':
                                swamps += 1
                            elif land.lower() == 'island':
                                islands += 1
                            elif land.lower() == 'forest':
                                forests += 1
                        with open(f'{path}/{stripCard(cmdr_name)}/{stripCard(cmdr_name)}_decklist.txt', 'a') as f:
                            if plains > 0:
                                f.write(f'{plains}, Plains\n')
                            if mountains > 0:
                                f.write(f'{mountains}, Mountain\n')
                            if swamps > 0:
                                f.write(f'{swamps}, Swamp\n')
                            if islands > 0:
                                f.write(f'{islands}, Island\n')
                            if forests > 0:
                                f.write(f'{forests}, Forest\n')
                    status.update(label="Finished adding cards!", state="complete")
        elif st.session_state.add_input_method == 'File Upload':
            added=st.file_uploader("Enter text file of cards to add: ", key='add_file_uploader')
            cmdr_name = st.text_input("Enter the name of the commander: ", key='add_cmdr_name_input')
            if added is not None:
                content = added.getvalue().decode('utf-8')
                card_names = [line.strip() for line in content.splitlines()]
                with st.status(label="Adding cards to decklist...", state="running") as status:
                    for card_name in card_names:
                        card = Card(card_name)
                        if card.is_basic_land:
                            basics.append(card.name)
                            count+=1
                            continue
                        card_name = card_name[2:] if len(card_name) > 2 else card_name
                        card.add_to_decklist(cmdr_name)
                        count+=1
                    if basics:
                        for land in basics:
                            if land.lower() == 'plains':
                                plains += 1
                            elif land.lower() == 'mountain':
                                mountains += 1
                            elif land.lower() == 'swamp':
                                swamps += 1
                            elif land.lower() == 'island':
                                islands += 1
                            elif land.lower() == 'forest':
                                forests += 1
                        with open(f'{path}/{stripCard(cmdr_name)}/{stripCard(cmdr_name)}_decklist.txt', 'a') as f:
                            if plains > 0:
                                f.write(f'{(100-count)/len(basics)}, Plains\n')
                            if mountains > 0:
                                f.write(f'{(100-count)/len(basics)}, Mountain\n')
                            if swamps > 0:
                                f.write(f'{(100-count)/len(basics)}, Swamp\n')
                            if islands > 0:
                                f.write(f'{(100-count)/len(basics)}, Island\n')
                            if forests > 0:
                                f.write(f'{(100-count)/len(basics)}, Forest\n')
                    status.update(label="Finished adding cards!", state="complete")
                    
    elif james == 'Remove Cards':
        st.selectbox("Enter by file or text input", options=['File Upload', 'Text Input'], key='remove_input_method', placeholder="Enter by file or text input")
        if st.session_state.remove_input_method == 'Text Input':
            cmdr_name = st.text_input("Enter the name of the commander: ", key='remove_cmdr_name_input')
            new_cards=st.text_input("Enter card names (one per line): ", key='remove_text_area')
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

    elif james == 'View Decklists':
        lists = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
        cmdr_name = st.selectbox("Select a commander:", options=lists)
        if cmdr_name:
            deck_path = f'{path}/{cmdr_name}/{stripCard(cmdr_name)}_decklist.txt'
            if os.path.exists(deck_path):
                with open(deck_path, 'r') as f:
                    cards = [line.strip() for line in f if line.strip()]

                    if not cards:
                        st.info(f"{cmdr_name}'s decklist is currently empty.")
                    else:
                        selected_card = st.selectbox("Select a card to view", options=cards)
                        st.text_area(f"{cmdr_name}'s Decklist", value="\n".join(cards), height=300, key='display_area')
                        

                        if selected_card:
                            card = Card(selected_card)
                            card.show_image()
            else:
                st.error(f"No decklist found for {cmdr_name}.")

    elif james == 'Logout':
        st.session_state.logged_in = False
        st.rerun()

else:
    st.title("Welcome to the MTG Deck Manager! Please log in to access your decklists.")
    st.text_input("Username", key='login_username')
    st.text_input("Password", type="password", key='login_password')
    col1, col2 = st.columns(2)
    with col1:
        create_account = st.button("Create Account", key='create_btn')
    with col2:
        login= st.button("Log In", key='login_btn')
    
    if login and goodUser(st.session_state.login_username) and verify_password(st.session_state.login_password, st.session_state.login_username):
        st.success("Logged in successfully!")
        st.session_state.logged_in = True
        st.rerun()
    elif create_account:
        if st.session_state.login_username and st.session_state.login_password:
            with open('users.txt', 'a') as f:
                f.write(f"{st.session_state.login_username}\n")
            with open('passwords.txt', 'a') as f:
                hashed = bcrypt.hashpw(st.session_state.login_password.encode('utf-8'), bcrypt.gensalt())
                f.write(f"{hashed}\n")
            st.success("Account created successfully!")
            st.session_state.logged_in = True
            st.rerun()
        else:
            st.error("Please fill in all fields.")
    elif login or create_account:
        st.error("Invalid username or password. Please try again or create an account if you don't have one.")


