import re
import os
import requests
import pandas as pd
import streamlit as st

#run command: python3 -m streamlit run card_app.py
deckToAdd=''
deckToChange=''
display=''
added=[]
removed=[]
unsure=[]
art=[]

def getDeckChanges():
    st.button("Edit by text", key='textEdit'); st.button("Edit by file", key='fileEdit')
    decklist=""
    if st.session_state.textEdit:
        decklist=st.text_area("Enter changes to deck (such as 'Export as plain text' from Moxfield): ")
    elif st.session_state.fileEdit:
        decklist=st.file_uploader("Upload a text file with changes to the deck (.txt, perhaps?) ")
    global added, removed, unsure
    added=[]
    removed=[]
    unsure=[]
    if st.session_state.fileEdit and decklist is not None:
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
                        with open(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(card)}.png', 'wb') as fo:
                            os.remove(f'{path}/decks/{stripCard(deckToChange)}/{stripCard(card)}.png')
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
                'Image': art
            }).set_index('Card Name')
            return st.table(deck)
    except Exception as e:
        st.error(f"An error occurred: [{e}].")
def addDeckToList(deckToAdd):
    # Basic lands count to zero for addition purposes
    forestCount=0
    addForests=False
    plainsCount=0
    addPlains=False
    mountainCount=0
    addMountains=False
    swampCount=0
    addSwamps=False
    islandCount=0
    addIslands=False
    try:
        cmdr_name=stripCard(deckToAdd)
        os.makedirs(f'{path}/decks/{cmdr_name}', exist_ok=True)
        with open(f'{path}/decks/{cmdr_name}/{cmdr_name}.txt', 'w') as f:
            f.write(f'{cmdr_name}\n')
            st.write(f'Added {cmdr_name} to decklist.')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while creating decklist.")
    creation=st.text_input("Enter cards to add to decklist (such as 'Export as plain text' from Moxfield): ").split(r' \d ')
    try:
        with open(f'{path}/decks/{cmdr_name}/{cmdr_name}.txt', 'r+') as f:
            for card in creation:
                if card.strip() == '':
                    continue
                if card.strip().lower()=='forest':
                    forestCount+=1
                    addForests  = True
                    continue
                elif card.strip().lower()=='plains':
                    plainsCount+=1
                    addPlains = True
                    continue
                elif card.strip().lower()=='mountain':
                    mountainCount+=1   
                    addMountains = True 
                    continue
                elif card.strip().lower()=='swamp':
                    swampCount+=1
                    addSwamps = True
                    continue
                elif card.strip().lower()=='island':
                    islandCount+=1    
                    addIslands = True
                    continue
                else :
                    card=stripCard(card)
                    f.write(f'1, {card}\n')
                    st.write(f'Added {card} to {cmdr_name} decklist.')
            if addForests:
                f.write(f'{forestCount} Forest\n')
                forestCount=0
                addForests=False
            if addPlains:
                f.write(f'{plainsCount} Plains\n')
                plainsCount=0
                addPlains=False
            if addMountains:
                f.write(f'{mountainCount} Mountain\n')
                mountainCount=0
                addMountains=False
            if addSwamps:
                f.write(f'{swampCount} Swamp\n')
                swampCount=0
                addSwamps=False
            if addIslands:
                f.write(f'{islandCount} Island\n')
                islandCount=0
                addIslands=False
            st.write(f'Added basic lands to {cmdr_name} decklist.')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while adding cards to decklist.")
    getArt(creation)

def getArt(listOfCards):
    global art
    art=[]
    for card in listOfCards:
        card=stripCard(card)
        try:
            response = requests.get(f"https://api.scryfall.com/cards/named?exact={stripCard(card)}")
            if response.status_code == 200:
                card_data = response.json()
                image_url = card_data['image_uris']['normal']
                image_response = requests.get(image_url)
                if image_response.status_code == 200:
                    art[card] = image_response.content
                    os.makedirs(f'{path}/decks/{stripCard(deckToChange)}', exist_ok=True)
                    with open (f'{path}/decks/{stripCard(deckToChange)}/{card}.png', 'wb') as img_file:
                        img_file.write(image_response.content)
                else:
                    st.error(f"Failed to download image for {stripCard(card)}.")
            else:
                st.error(f"Failed to fetch data for {stripCard(card)}.")
        except Exception as e:
            st.error(f"An error occurred: [{e}] while fetching card data and getting images.")
path = '/workspaces/CardStuffs'

st.title("Deck Editor")

st.subheader("Edit Deck")
st.button("Edit Deck", key="edit")
deckToChange = st.text_input("What commander to edit? ")

st.subheader("Display Deck")
st.button("Display Deck", key="display")
display=st.text_input("Which commander to display? ")

st.subheader("Add Deck")
st.button("Add Deck to List", key="addDeck")
deckToAdd = st.text_input("Which commander to add? ")
if __name__ == "__main__"  :
    if st.session_state.display:
       displayDeck(display)

    if st.session_state.edit:
       getDeckChanges()
       addCards(deckToChange)
       removeCards(deckToChange)
       displayDeck(deckToChange)

    if st.session_state.addDeck:
       addDeckToList(deckToAdd)
    