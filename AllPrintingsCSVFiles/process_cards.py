import streamlit as st


##LISTS FOR SITE CHECKBOXES##
format_list=["Don't Care", "Alchemy", "Brawl", "Commander", "Duel Commander", "Explorer", "Frontier", "Historic", "Historic Brawl", "Legacy", "Modern", "Pauper", "Pioneer", "Standard", "Vintage"]
display_list=["No dupes", "English Only", "Common", "Uncommon", "Rare", "Mythic Rare"]
must_be=["White", "Blue", "Black", "Red", "Green"]
allowed_colors=["White", "Blue", "Black", "Red", "Green"]
cannot_be=["White", "Blue", "Black", "Red", "Green"]
allowed_types=["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal", "Legendary"]
not_allowed_types=["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal", "Legendary"]
sort_by_list=["CMC","EDH Rank","Salty","Price"]
##############################################################################
st.title("MTG Card Search")
##Format selection
st.selectbox("Format", format_list, key="format")
##Name and set
st.text_area("Card Name Contains", height=50, key="name_contains")
st.text_area("Set Name Contains", height=50, key="set_name_contains")
st.subheader("Display list")
col1, col2, col3, col4, col5, col6 = st.columns(6)
with col1:    st.checkbox("No dupes", key="display_no_dupes")
with col2:    st.checkbox("English Only", key="display_english_only")
with col3:    st.checkbox("Common", key="display_common")
with col4:    st.checkbox("Uncommon", key="display_uncommon")
with col5:    st.checkbox("Rare", key="display_rare")
with col6:    st.checkbox("Mythic Rare", key="display_mythic_rare")
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
with col1:    st.text_area("Power Greater Than", height=100, key="power_gt")

with col2:    st.text_area("Power Less Than", height=100, key="power_lt")
##Toughness range
col3, space, col4 = st.columns(3)
with col3:    st.text_area("Toughness Greater Than", height=100, key="toughness_gt")

with col4:    st.text_area("Toughness Less Than", height=100, key="toughness_lt")
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
##Sort by
st.selectbox("Sort by", sort_by_list, key="sort_by")
##############################################################################