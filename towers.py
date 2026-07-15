import matplotlib.pyplot as plt
import numpy as np

coords_path = 'coords.txt'


def read_coords(path):
    towers = []
    portals = []
    with open(path, 'r') as f:
        for line in f:
            s = line.strip()
            if not s:
                continue
            last = s[-1].lower()
            coords_str = s[:-1].strip()
            if last == 't':
                towers.append(coords_str)
            elif last == 'p':
                portals.append(coords_str)
    return towers, portals


def clean_coords(coords):
    cleaned = []
    for coord in coords:
        parts = coord.split()
        if not parts:
            continue
        try:
            cleaned.append([float(c) for c in parts])
        except ValueError:
            continue
    return cleaned


def plot_towers_and_portals(towers, portals):
    towers = clean_coords(towers)
    portals = clean_coords(portals)

    if len(towers) == 0 and len(portals) == 0:
        print('No tower or portal coordinates to plot.')
        return

    towers = np.array(towers) if len(towers) else np.empty((0, 3))
    portals = np.array(portals) if len(portals) else np.empty((0, 3))

    if towers.ndim == 1:
        towers = towers.reshape(1, -1)
    if portals.ndim == 1:
        portals = portals.reshape(1, -1)

    fig, ax = plt.subplots()
    if towers.size:
        ax.scatter(towers[:, 0], towers[:, 2], c='blue', label='Towers')
    if portals.size:
        ax.scatter(portals[:, 0], portals[:, 2], c='red', label='Portals')

    ax.set_xlabel('X Coordinate')
    ax.set_ylabel('Z Coordinate')
    ax.set_title('Towers and Portals')
    if towers.size or portals.size:
        ax.legend()
    ax.grid()
    plt.savefig('towers_portals.png')

    avg_ty = None
    avg_py = None
    if towers.size:
        avg_ty = float(np.mean(towers[:, 1]))
    if portals.size:
        avg_py = float(np.mean(portals[:, 1]))

    print(f"Average Y coordinate for towers: {avg_ty}")
    print(f"Average Y coordinate for portals: {avg_py}")


if __name__ == "__main__":
    towers, portals = read_coords(coords_path)
    plot_towers_and_portals(towers, portals)