
added=[]
removed=[]
unsure=[]
deck={}
decklist=[]

import re
import fileinput
import requests
import pandas as pd
import streamlit as st
st.title("Deck Sorter")

##Need to update to work with file
def editDeck():
  decklist=input("Enter decklist file: ")
  try:
    with open(decklist, 'r') as file:
     decklist=file.read().splitlines()
     for line in decklist:
       line=line.strip()
       if re.search("Added", line, re.IGNORECASE):
         card=re.sub(r"Added", "", line, re.IGNORECASE).strip()
         added.append(card)
       elif re.search("Removed",line, re.IGNORECASE):
         card=re.sub(r"Removed", "", line, re.IGNORECASE).strip()
         removed.append(card)
       else:
         unsure.append(line)
    print(f"Unsure: {unsure}\n")
    print(f"Added: {added}\n")
    print(f"Removed: {removed}\n")
     
    
    
  except Exception as e:
     print(f"An error occurred: {e}")
  #Adding cards
  try:
    with open('decks.txt','r') as file:
     try:
      print("Reading file to add to.")
      lines=file.readlines()
      doneAdding=False
      commander_=input("Which commander to edit? ")
      with open('decks.txt','w') as file_:
       while not doneAdding:
        print("Writing deck (in addition mode). Please wait!")
        for card___ in lines:
         match_c=re.search(commander_, card___)
         if match_c:
           file_.write(card___)
           for addition in added:
             file_.write(f'\n1, {addition}')
             print(f'Added {addition} to {commander_}')
         else:
           file_.write(card___)
        doneAdding=True
             
     except Exception as e:
      print(f"An error occurred: [{e}] while adding.")
      
  #Removing Cards
    try:
     with open('decks.txt','r') as fr:
      print("Reading deck.")
      lines=fr.readlines()
      found2=False
      stop_count2=0
     with open('decks.txt','w') as fw:
       print("Writing deck (in removal mode). Please wait!")
       removed_count=0
       for card___ in lines:
        match_c=re.search(commander_, card___)
        match_stop=re.search("Commander:", card___)
        if match_c:
          if found2==True:
            continue
          else:
           found2=True
           print(f'Found {card___} to edit.') 
        if found2==True:
         for cut in removed:
          match_cut=re.search(cut,card___)
          if not match_stop: 
            if not match_cut:
              fw.write(card___)
            else:
              print(f"Removing {cut} from {commander_}")
              removed_count+=1
          elif stop_count2==0:
           print('Found commander again!')
           stop_count2+=1
          else:
           break
         if removed_count==0:
          print(f'No cards removed from {commander_}.')
    except Exception as e:
      print(f"An error occurred: [{e}] while removing.")
           
       
            
           
    #if found==False:
     #print(f'Card {commander_} not found.')
    
  except Exception as e:
      print(F"An error occured: {e}")

def getDeck():
  deck={} 
  action=input("Enter cards by (T)ext or by (F)ile? ").upper()
  if action=='T':
    cards=input("Enter deck as plain text: ").split('\n')
    ##Handling for text entry needed.
    print(deck)
  if action=='F':
    stuff=input("Enter decklist file name: ")
    try:
      with open(stuff, 'r') as file:
        cards_=file.read().split('\n')
        for card_ in cards_:
          match=re.search(r"(\d+)\s*(.*)", card_)
          if match:
           quantity = int(match.group(1))
           name = match.group(2)
           deck.update({name : quantity})
    except Exception as e:
      print(F"An error occured: {e}")
    try:
      with open('decks.txt', 'a') as file:
        cmdr=input("Enter commander: ")
        file.write(f"\n\nCommander: 1 {cmdr}\n\n")
        for name, qty in deck.items():
            if name!=cmdr:
             file.write(f"{qty} {name}\n")
             deck.update({name : qty})
    except FileNotFoundError:
     print("File not found.")
  else:
    print("Invalid input.")


def viewDeck():
  commander=input("Enter commander: ")
  found=False
  try:
    with open('decks.txt','r') as file:
      stop_count=0
      for card__ in file.read().split('\n'):
        match_c=re.search(commander, card__)
        match_stop=re.search("Commander:", card__)
        if match_c:
          if found==True:
            continue
          else:
           found=True
           print(f'Found {card__}')
        if found==True:
           if not match_stop:
            print(card__)
            continue
           elif stop_count==0:
             stop_count+=1
           else:
             break
            
           
    if found==False:
     print(f'Commander {commander} not found.')
    
  except Exception as e:
      print(F"An error occured: {e}")



while 1:
  try:
   action=int(input("1: Add decklist.\n2: Edit decklist.\n3: View Decklist.\n4: Quit. "))
  except ValueError as exception :
   print("Error:", str(exception))
   continue
  if (action==1):
    getDeck()
  if (action==2):
    editDeck()
  if (action==3):
    viewDeck()
  if action==4:
    print("Quitting.")
    break
