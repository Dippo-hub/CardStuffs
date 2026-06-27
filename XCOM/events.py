import random as r
import time as t

titles_and_rewards = {
    "Settlement" : "Rookies",
    "Fire Axis": "Scientist",
    "Stockade" : "Engineer",
    "Downed UFO": "Alien Alloys",
    "Ruined Camp" : "Supplies",
    "Raided Facility" : "Alien Alloys and Elerium Crystals",
    "Informants" : "Intel"
}

titles = [title for title in titles_and_rewards.keys()]
rewards =  [titles_and_rewards[key] for key in titles_and_rewards.keys()]



def day():
    t.sleep(2)
    return None

class Event:
    def __init__(self):
        self.title = r.choice(titles)
        self.reward = titles_and_rewards[self.title]
        self.scan_time = r.randint(5, 9)

    def scan(self):
        for d in range(self.scan_time):
            day()
            if r.randint(1,10) < 2:
                print("New Mission!")
                self.scan_time -= (d+1)
                return self.scan_time, None
            print(f'{self.scan_time - d - 1} days left.')
        return self.scan_time, self.reward
    
    def display(self):
        return f"{self.title} ({self.reward}) : {self.scan_time} days. "


if __name__ == "__main__":
    event = Event()
    event.display()
    print(event.scan())