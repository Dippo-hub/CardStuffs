import re
import fileinput
import requests
import pandas as pd
import streamlit as st

#run command: 

def getDeckChanges():
     decklist=st.text_input("Enter decklist file: ")
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
        with open(f'{path}/decks/{stripCard(deckToChange)}.txt', 'r+') as f:
            for card in added:
                f.write(f'1, {card}\n')
                st.write(f'Added {card} to {deckToChange}')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while opening the file.")

def removeCards(deckToChange):
    try:
        with open(f'{path}/decks/{stripCard(deckToChange)}.txt', 'r+') as fi:
            lines = fi.readlines()
            for card in removed:
                for line in lines:
                    if stripCard(line) == card:
                        lines.remove(line)
                        st.write(f'Removed {card} from {deckToChange}')
    except Exception as e:
        st.error(f"An error occurred: [{e}] while opening the file.")

def displayDeck(deckToSee):
    art=[]
    try:
        with open(f'{path}/decks/{stripCard(deckToSee)}.txt', 'r') as f:
            st.write(f"Decklist for {deckToSee}:")
            for line in f:
                art.append(requests.get(f"https://api.scryfall.com/cards/named?exact={stripCard(line)}").json())
            deck=pd.DataFrame({
                'Card Name': [stripCard(line)],
                'Image': [art['image_uris']['normal']]
            }).set_index('Card Name')
            st.table(deck)
    except Exception as e:
        st.error(f"An error occurred: [{e}] while opening the file.")
path = '/workspace/Cardstuffs'

st.title("Deck Editor")
def main():
   if st.button("Edit Deck"):
       getDeckChanges()
       deckToChange=st.text_input("Which commander to edit? ")
       addCards(deckToChange)
       removeCards(deckToChange)
       displayDeck(deckToChange)
    