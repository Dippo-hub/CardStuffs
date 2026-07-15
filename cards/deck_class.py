import requests
import os
import streamlit as st

class Deck:
    def __init__(self, commander, cards=[]):
        self.commander = commander
        self.cards = cards

    def add_card(self, card):
        for c in self.cards:
            if c.split(' ', maxsplit=2)[1] == card.split(' ', maxsplit=2)[1]:  # Compare by card name
                c[0] = str(int(c[0]) + int(card.split(' ', maxsplit=2)[0]))  # Update quantity
                self.save()
                rerun()
                return
        self.cards.append(card)
        rerun()
        self.save()

    def remove_card(self, card, amount=1):
        for c in self.cards:
            if c.split(' ', maxsplit=2)[1] == card.split(' ', maxsplit=2)[1]:
                if int(c.split(' ', maxsplit=2)[0]) >= amount:
                    c[0] = str(int(c[0]) - amount)
                    if int(c[0]) == 0:
                        self.cards.remove(c)
                    self.save()
                    rerun()
                    return
        st.write(f"Card '{card}' not found in the deck.")

    def save(self):
        with open(f'decks/{self.commander}.txt', 'w') as f:
            f.write(f"Commander: {self.commander}\n")
            f.write("Cards:\n")
            if self.cards:
                for card in self.cards:
                    card = card.split(' ', maxsplit=2)  # Split on quantity/name
                    f.write(f"{card[0]} {card[1]}\n")
                    # Count duplicates including basics
            else:
                st.write("No cards in the deck to save.")
    
    def display(self):
        st.write(f"Commander: {self.commander}")
        st.write("Cards:")
        if self.cards:
            for card in self.cards:
                st.write(f"{card.replace('\n', ''  )}")
        else:
            st.write("No cards in the deck.")

def load_deck(commander):
    try:
        with open(f'decks/{commander}.txt', 'r') as f:
            lines = f.readlines()
            cards = [line for line in lines[2:]]  # Skip the first two lines (Commander and "Cards:")
            return Deck(commander, cards)
    except FileNotFoundError:
        st.write(f"No deck found for commander '{commander}'.")
        return Deck(commander)
    
def create_deck(new_commander=None, decklist=None):
    if new_commander and decklist:
        new_deck = Deck(new_commander, decklist)
        new_deck.save()
        st.write(f"Created new deck for commander: {new_commander}")
        decknames.append(new_commander)
    elif new_commander:
        new_deck = Deck(new_commander)
        new_deck.save()
        st.write(f"Created new deck for commander: {new_commander}")
        decknames.append(new_commander)

def rerun():
    st.session_state["data_updated"] = True

st.title("Deck Manager")

decknames = [f.split('.')[0] for f in os.listdir('decks') if f.endswith('.txt')]
if len(decknames) == 0:
    st.write("No decks found. Please create a deck first.")

new_commander = st.text_input("Enter the name of the new commander:")
decklist = st.text_area("Enter the decklist (one card per line, format: 'quantity card_name'):").splitlines()
st.button("Create New Deck", key="create_deck_button", on_click=create_deck, args=(new_commander, decklist))



st.selectbox('Select a deck', decknames, key='selected_deck')
deck = load_deck(st.session_state.selected_deck)
st.write(f"Loaded deck for commander: {deck.commander}")
with st.sidebar:
    deck.display()

c1, c2, c3 = st.columns(3)
st.subheader("Add a card to the deck")
with c1:
    name = st.text_input("Card Name", key='add_card_name')
with c2:
    quantity = st.number_input("Quantity", min_value=1, value=1, key='add_q')
with c3:
    if st.button("Add Card"):
        if name:
            deck.add_card(f"{quantity} {name}")
            st.write(f"Added {quantity} copies of '{name}' to the deck.")
        else:
            st.write("Please enter a card name.")

c1, c2, c3 = st.columns(3)
st.subheader("Remove a card from the deck")
with c1:
    name = st.text_input("Card Name", key='remove_card_name')
with c2:
    quantity = st.number_input("Quantity", min_value=1, value=1, key='remove_q')
with c3:
    if st.button("Remove Card"):
        if name:
            deck.remove_card(f"{quantity} {name}")
            st.write(f"Removed {quantity} copies of '{name}' from the deck.")
        else:
            st.write("Please enter a card name.")
            

