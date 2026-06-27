import random as r
from events import Event, day
from units import generate_random_soldier
from mission import Mission



class StrategicLayer:
    def __init__(self):
        self.days = 0
        self.events = []
        self.barracks = [generate_random_soldier(0, 0) for _ in range(12)]
        self.alloys = 0
        self.elerium = 0
        self.resistance_contacts = 0
        self.max_contacts = 3
        self.intel = 0
        self.supplies = 0
        self.scientists = 0
        self.engineers = 0
        self.uncontacted_regions = ['East America', 'West America', 'New Central America', 'New Brazi;', 'New Chile', 'New Oceania', 'New Indonesia', 'NE Asia', 'SE Asia', 'NW Asia', 'SW Asia', 'South Africa', 'New Egypt', 'Newer Guinea', 'New UK', 'New Slavia']
        self.starting_region = r.choice(self.uncontacted_regions)
        self.uncontacted_regions.remove(self.starting_region)
        print(f'Starting in {self.starting_region}')
        self.add_event()

    def add_event(self):
        if len(self.events) > 5:
            return
        event = Event()
        self.events.append(event)

    def reward(self, reward):
        if reward == 'Engineer':
            print("Engineer Recruited!")
            self.engineers += 1
        elif reward == 'Scientist':
            print("Scientist Recruited!")
            self.scientists+=1
        elif reward == 'Supplies':
            supplies = r.randint(50, 150)
            print("Supplies added: ", str(supplies))
            self.supplies += supplies
        elif reward == 'Alien Alloys':
            supplies = r.randint(20, 50)
            print("Alloys added: ", str(supplies))
            self.alloys += supplies
        elif reward == 'Alien Alloys and Elerium Crystals':
            supplies = r.randint(20, 50)
            print("Alloys added: ", str(supplies))
            self.alloys += supplies
            supplies = r.randint(20, 35)
            print("Elerium added: ", str(supplies))
            self.elerium += supplies
        elif reward == 'Intel':
            intel = r.randint(60, 120)
            print("Intel Added: ", str(intel))
            self.intel += intel
        elif reward == 'Rookies':
            size = r.randint(1,3)
            for _ in range(size):
                self.barracks.append(generate_random_soldier(0, 0))
                print(f"Added Rk. {self.barracks[-1].name} to the Avenger!")
        elif reward is None:
            self.events.append("Mission")

    def display_events(self):
        for i, event in enumerate(self.events, start=1):
            print(f'{i}: {event.display()}')
        try:
            selection = int(input("Select event to scan: "))

            print(f"Scanning {self.events[selection-1].title}")
            days, reward = self.events[selection-1].scan()
            self.days += days
            self.reward(reward)

            self.events.remove(self.events[selection-1])
            if len(self.events) == 0: 
                self.add_event()
            if r.randint(0, 5) > 3:
                self.add_event()
        except IndexError:
            print("Please select an event in range.")

    def display_stats(self):
        print(f'Contacts: {self.resistance_contacts}/{self.max_contacts}, Scientists: {self.scientists}, Engineers: {self.engineers}, Alloys: {self.alloys}, Elerium: {self.elerium}, Intel: {self.intel}, Supplies: {self.supplies}')

if __name__ == "__main__":
    st = StrategicLayer()
    while True:
        st.display_stats()
        st.display_events()
        print(st.days)
    