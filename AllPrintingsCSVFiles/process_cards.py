import streamlit as st
import requests
import pandas as pd
import os
import re
import socket
##Globals##
searches={"format": "Don't Care",
          "name_contains": "",
          "set_name_contains": "",
          "display_no_dupes": True,
          "display_english_only": True,
          "display_common": True,
          "display_uncommon": True,
          "display_rare": True,
          "display_mythic_rare": True,
          "display_special": True,   
          "must_be_white": False,
          "must_be_blue": False,
          "must_be_black": False,
          "must_be_red": False,
          "must_be_green": False,
          "allowed_colors_white": False,
          "allowed_colors_blue": False,
          "allowed_colors_black": False,
          "allowed_colors_red": False,
          "allowed_colors_green": False,
          "cannot_be_white": False,
          "cannot_be_blue": False,
          "cannot_be_black": False,
          "cannot_be_red": False,
          "cannot_be_green": False,
          "power_low": "",
          "power_high": "",
          "toughness_low": "",
          "toughness_high": "",
          "cmc_low": "",
          "cmc_high": "",
          "subtype": "",
          "supertype": "",
          "allowed_types_artifact": False,
          "allowed_types_creature": False,
          "allowed_types_enchantment": False,
          "allowed_types_instant": False,
          "allowed_types_land": False,
          "allowed_types_planeswalker": False,
          "allowed_types_sorcery": False,
          "allowed_types_tribal": False,
          "allowed_types_legendary": False,
          "not_allowed_types_artifact": False,
          "not_allowed_types_creature": False,
          "not_allowed_types_enchantment": False,
          "not_allowed_types_instant": False,
          "not_allowed_types_land": False,
          "not_allowed_types_planeswalker": False,
          "not_allowed_types_sorcery": False,
          "not_allowed_types_tribal": False,
          "not_allowed_types_legendary": False,
          "and1": "",
          "and2": "",
          "and3": "",
          "and4": "",
          "and5": "",
          "and6": "",
          "and7": "",
          "and8": "",
          "or1": "",
          "or2": "",
          "or3": "",
          "or4": "",
          "not1": "",
          "not2": "",
          "not3": "",
          "not4": "",
          "sort_by": "CMC"
          }
onward = ""
results = []
recieved_data = []
## request {MUST_HAVE:----:
#           ALLOWED_HAVE:1-1-1-1-1:
#           NOT_ALLOWED_HAVE:----:
#           ALLOWED_TYPES:1-1-1-1-1-1-0-0-0-0:
#           NOT_ALLOWED_TYPES:0-0-0-0-0-0-0-0-0-0:
#           name_filter:avatar:
#           text1::
#           text2::
#           text3::
#           text4::
#           text5::
#           text6::
#           low::
#           high::
#           OR_TEXT:---:
#           low_power::
#           high_power::
#           low_toughness::
#           high_toughness::
#           super_type::
#           type::
#           set_filter::
#           eliminate_dups:1:
#           english:1:
#           mythic:1:
#           rare:1:
#           uncommon:1:
#           common:1:
#           special:1
#           }

def transform_to_request(searches):
    request = {}
    request["MUST_HAVE"] = "".join(["1-" if searches[f"must_be_{color}"] else "0-" for color in socket_colors])
    request["ALLOWED_HAVE"] = "".join(["1-" if searches[f"allowed_colors_{color}"] else "0-" for color in socket_colors])
    request["NOT_ALLOWED_HAVE"] = "".join(["1-" if searches[f"cannot_be_{color}"] else "0-" for color in socket_colors])
    request["ALLOWED_TYPES"] = "".join(["1-" if searches[f"allowed_types_{type.lower()}"] else "0-" for type in allowed_types])
    request["NOT_ALLOWED_TYPES"] = "".join(["1-" if searches[f"not_allowed_types_{type.lower()}"] else "0-" for type in not_allowed_types])
    request["name_filter"] = searches["name_contains"]
    request["text1"] = searches["and1"]
    request["text2"] = searches["and2"]
    request["text3"] = searches["and3"]
    request["text4"] = searches["and4"]
    request["text5"] = searches["and5"]
    request["text6"] = searches["and6"]
    request["text7"] = searches["and7"]
    request["text8"] = searches["and8"]
    request["OR_TEXT"] = "".join([searches[f"or{i}"] +"-" for i in range(1,4)])
    request["ntext1"] = searches["not1"]
    request["ntext2"] = searches["not2"]
    request["ntext3"] = searches["not3"]
    request["ntext4"] = searches["not4"]
    request["low"] = searches["cmc_low"]
    request["high"] = searches["cmc_high"]
    request["low_power"] = searches["power_low"]
    request["high_power"] = searches["power_high"]
    request["low_toughness"] = searches["toughness_low"]
    request["high_toughness"] = searches["toughness_high"]
    request["super_type"] = searches["supertype"]
    request["type"] = searches["subtype"]
    request["set_filter"] = searches["set_name_contains"]
    request["eliminate_dups"] = "1" if searches["display_no_dupes"] else "0"
    request["english"] = "1" if searches["display_english_only"] else "0"
    request["mythic"] = "1" if searches["display_mythic_rare"] else "0"
    request["rare"] = "1" if searches["display_rare"] else "0"
    request["uncommon"] = "1" if searches["display_uncommon"] else "0"
    request["common"] = "1" if searches["display_common"] else "0"
    request["special"] = "1" if searches["display_special"] else "0"
    request["sort_by"] = searches["sort_by"]
    request["legality_selected"] = searches["format"].lower().replace(" ", "_").replace("'", "")
    st.write(request)
    return request

def send_request(request):

    HOST =  '127.0.0.1' # The server's hostname or IP address
    PORT = 12345       # The port used by the server
    recieved_data = []
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(120.0)
            s.connect((HOST, PORT))
            s.sendall(str(request).encode(encoding='utf-8'))
            st.write("Search sent!")
            data = s.recv(1024)
            while not re.search(pattern="DONE:", string=data.decode('utf-8')):
                if not data:
                    st.sidebar.write("Shit data")
                st.sidebar.write(data.decode("utf-8"))
                data = s.recv(1024)
            st.sidebar.write(data.decode("utf-8"))
    except socket.timeout:
        st.error("Too slow!")
    except ConnectionRefusedError:
        st.write("Could not connect to Perl!")

    
        



text_ands = ["and1", "and2", "and3", "and4", "and5", "and6", "and7", "and8"]
text_ors = ["or1", "or2", "or3", "or4"]
text_nots = ["not1", "not2", "not3", "not4"]

##LISTS FOR SITE CHECKBOXES##
format_list=["Don't Care", "Alchemy", "Brawl", "Commander", "Duel Commander", "Explorer", "Frontier", "Historic", "Historic Brawl", "Legacy", "Modern", "Pauper", "Pioneer", "Standard", "Vintage"]
display_list=["No dupes", "English Only", "Common", "Uncommon", "Rare", "Mythic Rare"]
must_be=["White", "Blue", "Black", "Red", "Green"]
allowed_colors=["White", "Blue", "Black", "Red", "Green"]
cannot_be=["White", "Blue", "Black", "Red", "Green"]
allowed_types=["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal", "Legendary"]
not_allowed_types=["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal", "Legendary"]
sort_by_list=["CMC","EDH Rank","Salty","Price"]
socket_colors = ["white", "blue", "green", "red", "black"]
###############################################################################

def search(searches):
    text_ands = [searches["and1"], searches["and2"], searches["and3"], searches["and4"], searches["and5"], searches["and6"], searches["and7"], searches["and8"]]
    text_ors = [searches["or1"], searches["or2"], searches["or3"], searches["or4"]]
    text_nots = [searches["not1"], searches["not2"], searches["not3"], searches["not4"]]
    
ready = True
if not ready:
    with st.status(label="Preparing...", expanded=True, state="running") as status:
        card_foreign_data = pd.read_csv('AllPrintingsCSVFiles/cardForeignData.csv')
        st.write("Loading card identifiers...")
        card_identifiers = pd.read_csv('AllPrintingsCSVFiles/cardIdentifiers.csv')
        st.write("Loading card legalities...")
        card_legalities = pd.read_csv('AllPrintingsCSVFiles/cardLegalities.csv')
        st.write("Loading card prices...")
        card_prices = pd.read_csv('AllPrintingsCSVFiles/cardPrices.csv')
        st.write("Loading card purchase URLs...")
        card_purchase_uris = pd.read_csv('AllPrintingsCSVFiles/cardPurchaseUrls.csv')
        st.write("Loading card rulings...")
        card_rulings = pd.read_csv('AllPrintingsCSVFiles/cardRulings.csv')
        st.write("Loading cards...")
        cards = pd.read_csv('AllPrintingsCSVFiles/cards.csv', low_memory=False)
        st.write("Loading set booster contents...")
        set_booster_contents = pd.read_csv('AllPrintingsCSVFiles/setBoosterContents.csv')
        st.write("Loading set booster content weights...")
        set_booster_content_weights = pd.read_csv('AllPrintingsCSVFiles/setBoosterContentWeights.csv')
        st.write("Loading set booster sheets...")
        set_booster_sheets = pd.read_csv('AllPrintingsCSVFiles/setBoosterSheets.csv')
        st.write("Loading sets...")
        sets = pd.read_csv('AllPrintingsCSVFiles/sets.csv')
        st.write("Loading set translations...")
        set_translations = pd.read_csv('AllPrintingsCSVFiles/setTranslations.csv')
        st.write("Loading token identifiers...")
        token_identifiers = pd.read_csv('AllPrintingsCSVFiles/tokenIdentifiers.csv')
        st.write("Loading tokens...")
        tokens = pd.read_csv('AllPrintingsCSVFiles/tokens.csv')
        ready = True
        status.update(label="Ready!", state="complete")


st.title("MTG Card Search")

##Format selection
st.selectbox("Format", format_list, key="format")
##Name and set
st.text_input("Card Name Contains", key="name_contains")
st.text_input("Set Name Contains", key="set_name_contains")
st.subheader("Display list")
col1, col2 = st.columns(2)
with col1:    st.checkbox("No dupes", key="display_no_dupes", value=True)
with col2:    st.checkbox("English Only", key="display_english_only", value=True)
col3, col4, col5, col6, col7 = st.columns(5)
with col3:    st.checkbox("Common", key="display_common", value=True)
with col4:    st.checkbox("Uncommon", key="display_uncommon", value=True)
with col5:    st.checkbox("Rare", key="display_rare", value=True)
with col6:    st.checkbox("Mythic", key="display_mythic_rare", value=True)
with col7:    st.checkbox("Special", key="display_special", value=True)

##Color selection
st.subheader("Must be:")
col7, col8, col9, col10, col11 = st.columns(5)
with col7:    st.checkbox("White", key="must_be_white")
with col8:    st.checkbox("Blue", key="must_be_blue")
with col9:    st.checkbox("Black", key="must_be_black")
with col10:   st.checkbox("Red", key="must_be_red")
with col11:   st.checkbox("Green", key="must_be_green")

st.subheader("Allowed Colors:")
col12, col13, col14, col15, col16 = st.columns(5)
with col12:    st.checkbox("White", key="allowed_colors_white")  
with col13:    st.checkbox("Blue", key="allowed_colors_blue")
with col14:    st.checkbox("Black", key="allowed_colors_black")
with col15:    st.checkbox("Red", key="allowed_colors_red")
with col16:   st.checkbox("Green", key="allowed_colors_green")

st.subheader("Cannot be:")
col17, col18, col19, col20, col21 = st.columns(5)
with col17:    st.checkbox("White", key="cannot_be_white")
with col18:    st.checkbox("Blue", key="cannot_be_blue")
with col19:    st.checkbox("Black", key="cannot_be_black")
with col20:    st.checkbox("Red", key="cannot_be_red")
with col21:    st.checkbox("Green", key="cannot_be_green")

##Power range
col1, sign, col2 = st.columns(3)
with col1:    st.text_input("Power Greater Than", key="power_low")
with col2:    st.text_input("Power Less Than", key="power_high")

##Toughness range
col3, space, col4 = st.columns(3)
with col3:    st.text_input("Toughness Greater Than", key="toughness_low")
with col4:    st.text_input("Toughness Less Than", key="toughness_high")

##CMC range
col5, space2, col6 = st.columns(3)
with col5:    st.text_input("CMC Greater Than", key="cmc_low")
with col6:    st.text_input("CMC Less Than", key="cmc_high")

##Subtype/Supertype selection
col1, col3 = st.columns(2)
with col1: st.text_input("Subtype:", key="subtype")
with col3: st.text_input("Supertype:", key="supertype")
##Type selection
st.subheader("Allowed Types:")
cols = st.columns(5)
with cols[0]:    st.checkbox("Artifact", key="allowed_types_artifact")
with cols[1]:    st.checkbox("Creature", key="allowed_types_creature")
with cols[2]:    st.checkbox("Enchantment", key="allowed_types_enchantment")
with cols[3]:    st.checkbox("Instant", key="allowed_types_instant")
with cols[4]:    st.checkbox("Land", key="allowed_types_land")
cols = st.columns(4)
with cols[0]:    st.checkbox("Planeswalker", key="allowed_types_planeswalker")
with cols[1]:    st.checkbox("Sorcery", key="allowed_types_sorcery")
with cols[2]:    st.checkbox("Tribal", key="allowed_types_tribal")
with cols[3]:    st.checkbox("Legendary", key="allowed_types_legendary")

st.subheader("Not Allowed Types:")
cols = st.columns(5)
with cols[0]:    st.checkbox("Artifact", key="not_allowed_types_artifact")
with cols[1]:    st.checkbox("Creature", key="not_allowed_types_creature")
with cols[2]:    st.checkbox("Enchantment", key="not_allowed_types_enchantment")
with cols[3]:    st.checkbox("Instant", key="not_allowed_types_instant")
with cols[4]:    st.checkbox("Land", key="not_allowed_types_land")
cols = st.columns(4)
with cols[0]:    st.checkbox("Planeswalker", key="not_allowed_types_planeswalker")
with cols[1]:    st.checkbox("Sorcery", key="not_allowed_types_sorcery")
with cols[2]:    st.checkbox("Tribal", key="not_allowed_types_tribal")
with cols[3]:    st.checkbox("Legendary", key="not_allowed_types_legendary")

##Text Contains
st.subheader("Text Ands:")
ands = st.columns(4)
with ands[0]:    st.text_input("", key="and1")
with ands[1]:    st.text_input("", key="and2")
with ands[2]:    st.text_input("", key="and3")
with ands[3]:    st.text_input("", key="and4")
ands = st.columns(4)
with ands[0]:    st.text_input("", key="and5")
with ands[1]:    st.text_input("", key="and6")
with ands[2]:    st.text_input("", key="and7")
with ands[3]:    st.text_input("", key="and8")

st.subheader("Text Ors:")
ors = st.columns(4)
with ors[0]:    st.text_input("", key="or1")
with ors[1]:    st.text_input("", key="or2")
with ors[2]:    st.text_input("", key="or3")
with ors[3]:    st.text_input("", key="or4")

st.subheader("Text Nots:")
nots = st.columns(4)
with nots[0]:    st.text_input("", key="not1")
with nots[1]:    st.text_input("", key="not2")
with nots[2]:    st.text_input("", key="not3")
with nots[3]:    st.text_input("", key="not4")

##Sort by
st.selectbox("Sort by", sort_by_list, key="sort_by")

##Search
st.button("Search", key="search")
if st.session_state.search:
    with st.sidebar.status(label = "Thinking...", state="running") as status:
        try:
            for key in searches.keys():
                searches[key] = st.session_state[key]
            send = transform_to_request(searches)
            start = "request:"
            onward = "".join(f"{key}:{send[key]}:" for key in send.keys())
            go_forth = start + onward + "\n"
            st.write(go_forth)
            results = send_request(go_forth)
            status.update(label="Stuff!", state="complete")
        except Exception as e:
            st.sidebar.error(f"An error occurred: {str(e)}")
            status.update(label="SHIT", state="error")
##Display results
with st.sidebar as left:
    st.header("Results:")
    st.write(results)

##############################################################################