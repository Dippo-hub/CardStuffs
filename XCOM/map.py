import random as r
import math

def distance(x1,x2,y1,y2):
    return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))

class Map:
    def __init__(self, size='medium'):
        if size == 'small':
            self.width = 15
            self.height = 15
        elif size == 'medium':
            self.width = 30
            self.height = 30
        else:
            self.width = 45
            self.height = 45

        self.grid = [[None for _ in range(self.width)] for _ in range(self.height)]
        self.cover = [[r.randint(0, 10) < 3 for _ in range(self.width)] for _ in range(self.height)]


    def display(self):
        for y in range(self.height):
            row = []
            for x in range(self.width):
                square = self.grid[y][x]
                cover = self.cover[y][x]

                if square is not None:
                    if square.hp > 0:
                        row.append(square.name[0])
                    else:
                        row.append('.')
                elif cover:
                    row.append('k')
                else:
                    row.append('.')
            print(" ".join(row))

if __name__ == "__main__":
    from units import Unit, initialize_enemy
    map = Map('small')
    map.grid[7][14] = initialize_enemy('Gatekeeper 00')
    print(map.grid[7][14].name)
    map.display()

    