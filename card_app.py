import re
import requests
import pandas as pd
import streamlit as st

#run command: python3 -m streamlit run card_app.py

def getDeckChanges():
     decklist=st.text_input("Enter decklist file: ")
     global added, removed, unsure
     added=[]
     removed=[]
     unsure=[]
     try:
       #opens deck changes file and saves it to decklist var
       with open(decklist, 'r') as file:
        decklist=file.read().splitlines()
        for line in decklist:
          line=line.strip()
          #if line contains "Added" or "Removed", it will be added to the appropriate list. If it contains neither, it will be added to the unsure list.
          if re.search("Added", line, re.IGNORECASE):
            card=re.sub(r"Added", "", line, re.IGNORECASE).strip()
            added.append(card)
          elif re.search("Removed",line, re.IGNORECASE):
            card=re.sub(r"Removed", "", line, re.IGNORECASE).strip()
            removed.append(card)
          else:
            unsure.append(line)
       st.write(f"Unsure: {unsure}")
       st.write(f"Added: {added}")
       st.write(f"Removed: {removed}")
     except Exception as e:
        st.error(f"An error occurred: {e}")

def stripCard(card):
    return re.sub(r"^\d+\s*,\s*", "", card).strip()

def addCards(deckToChange):
    try:
        #Creates file/folder if it doesn't exist, otherwise it opens the file and adds the cards to the decklist
        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(deckToChange)}.txt', 'r+') as f:
            for card in added:
                f.write(f'1, {card}\n')
                st.write(f'Added {card} to {deckToChange}')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while opening the file.")
    try:
        #Creates image in deck folder
        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(deckToChange)}.txt', 'r') as f:
            for line in f:
                card_name = stripCard(line)
                response = requests.get(f"https://api.scryfall.com/cards/named?exact={card_name}")
                if response.status_code == 200:
                    card_data = response.json()
                    image_url = card_data['image_uris']['normal']
                    image_response = requests.get(image_url)
                    if image_response.status_code == 200:
                        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(card_name)}.jpg', 'wb') as img_file:
                            img_file.write(image_response.content)
                    else:
                        st.error(f"Failed to download image for {card_name}.")
                else:
                    st.error(f"Failed to fetch data for {card_name}.")
    except Exception as e:
        st.error(f"An error occurred: [{e}] while fetching card data and getting images.")


def removeCards(deckToChange):
    try:
        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(deckToChange)}.txt', 'r+') as fi:
            lines = fi.readlines()
            for card in removed:
                for line in lines:
                    if stripCard(line) == stripCard(card):
                        lines.remove(line)
                        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(deckToChange)}.jpg', 'wb') as fo:
                            fo.remove(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(card)}.jpg')
                        st.write(f'Removed {card} from {deckToChange}')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while removing cards.")

def displayDeck(deckToSee):
    global art
    art=[]
    try:
        with open(f'{path}/decks/{stripCard(deckToSee)}/{stripCard(deckToSee)}.txt', 'r') as f:
            st.write(f"Decklist for {deckToSee}:")
            cards=f.read().splitlines()
            for line in cards:
                with open(f'{path}/decks/{stripCard(deckToSee)}/{stripCard(line)}.jpg', 'rb') as img_file:
                    art[stripCard(line)] = img_file.read()
            deck=pd.DataFrame({
                'Card Name': cards,
                'Image': art.values()
            }).set_index('Card Name')
            st.table(deck)
    except Exception as e:
        st.error(f"An error occurred: [{e}].")
path = '/workspace/Cardstuffs'

st.title("Deck Editor")
def main():
   if st.button("Edit Deck"):
       getDeckChanges()
       deckToChange=st.text_input("Which commander to edit? ")
       addCards(deckToChange)
       removeCards(deckToChange)
       displayDeck(deckToChange)
    