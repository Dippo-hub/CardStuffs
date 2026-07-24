import pygame
import math

# Initialize Pygame
class CombatMap:
    def __init__(self):
        self.title = input("Combat Title: ")
        self.enemies = []
        self.players = []
        try:
            self.width = int(input("Map Width: "))
        except TypeError:
            print("Enter a number.")
        try:
            self.height = int(input("Map height: "))
        except TypeError:
            print("Enter a number.")
        pygame.init()

        # Constants
        self.SCREEN_WIDTH = 800
        self.SCREEN_HEIGHT = 600
        self.HEX_RADIUS = 30  # Distance from center to any corner

        # Colors
        self.BACKGROUND_COLOR = (30, 30, 40)
        self.HEX_COLOR = (70, 130, 180)      # Steel Blue
        self.BORDER_COLOR = (255, 255, 255)   # White

        # Set up screen
        self.screen = pygame.display.set_mode((self.SCREEN_WIDTH, self.SCREEN_HEIGHT))
        pygame.display.set_caption(self.title)

    def get_hex_points(self, center_x, center_y, radius):
        """Calculates the 6 vertices of a pointy-topped hexagon."""
        points = []
        for i in range(6):
            # Angle in radians (30 degrees offset for pointy-topped hexes)
            angle_deg = 60 * i - 30
            angle_rad = math.pi / 180 * angle_deg
            x = center_x + radius * math.cos(angle_rad)
            y = center_y + radius * math.sin(angle_rad)
            points.append((x, y))
        return points

    def hex_to_pixel(self, q, r, radius):
        """Converts axial coordinates (q, r) to pixel coordinates (x, y)."""
        x = radius * (math.sqrt(3) * q + math.sqrt(3) / 2 * r)
        y = radius * (3.2 / 2 * r)  # 3/2 * radius vertically
        return x, y

    def draw_hex_map(self, radius):
        """Generates and draws a parallelogramatic hex grid mapping."""
        # Screen offset so the map doesn't clip off the top-left edge
        map_offset_x = 100
        map_offset_y = 100

        # Define grid bounds (change these loop ranges to resize your board)
        for q in range(0, 10):
            for r in range(0, 8):
                # 1. Convert grid coordinate to pixel position
                cx, cy = self.hex_to_pixel(q, r, radius)
                cx += map_offset_x
                cy += map_offset_y

                # 2. Get the 6 vertices
                vertices = self.get_hex_points(cx, cy, radius)

                # 3. Draw the hexagon fill
                pygame.draw.polygon(self.screen, self.HEX_COLOR, vertices)
                
                # 4. Draw the hexagon outline (thickness=2)
                pygame.draw.polygon(self.screen, self.BORDER_COLOR, vertices, 2)

    # Main Game Loop
    def run(self):
        running = True
        clock = pygame.time.Clock()

        while running:
            # Event handling
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

            # Render logic
            self.screen.fill(self.BACKGROUND_COLOR)
            self.draw_hex_map(self.HEX_RADIUS)
            
            # Update display
            pygame.display.flip()
            clock.tick(60)  # Maintain 60 FPS

        pygame.quit()


if __name__ == '__main__':
    c = CombatMap()
    c.run()