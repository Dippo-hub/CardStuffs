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
        self.cover = self.generate_cover()

    def in_bounds(self, x, y) -> bool:
        return 0 <= x < self.width and 0 <= y < self.height

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
                elif cover > 0:
                    row.append(str(cover))
                else:
                    row.append('.')
            print(" ".join(row))

    def generate_cover(self):
        cover = [[0 for _ in range(self.width)] for _ in range(self.height)]
        for y in range(self.height):
            for x in range(self.width):
                if cover[y][x-1]>0 or cover[y-1][x]>0 and self.in_bounds(x-1, y) and self.in_bounds(x, y-1):
                    if r.randint(0, 3) == 0:
                        cover[y][x] = 2
                else:
                    cover[y][x] = 1 if r.randint(0, 3) == 0 else 0
        return cover
    
    def move_unit(self, unit, new_x, new_y):
        if self.in_bounds(new_x, new_y) and self.grid[new_y][new_x] is None and distance(unit.x, new_x, unit.y, new_y) <= unit.mobility:
            self.grid[unit.y][unit.x] = None
            self.grid[new_y][new_x] = unit
            unit.x = new_x
            unit.y = new_y
            return True
        return False

if __name__ == "__main__":
    from units import Unit, initialize_enemy
    map = Map('small')
    map.grid[7][14] = initialize_enemy('Gatekeeper 00')
    print(map.grid[7][14].name)
    map.display()

    