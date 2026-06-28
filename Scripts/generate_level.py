import random
import json

WIDTH = 200
HEIGHT = 100

T_WALL = " "
T_FLOOR = "#"
T_DOOR = "#"
T_EMPTY = " "

class Room:
    def __init__(self, x, y, w, h):
        self.x = x
        self.y = y
        self.w = w
        self.h = h

    def center(self):
        return self.x + self.w // 2, self.y + self.h // 2

    def intersects(self, other):
        return not (
            self.x + self.w < other.x - 3 or
            self.x > other.x + other.w + 3 or
            self.y + self.h < other.y - 3 or
            self.y > other.y + other.h + 3
        )

def create_empty_map():
    return [[T_EMPTY for _ in range(WIDTH)] for _ in range(HEIGHT)]

def create_room(grid, room):
    for y in range(room.y, room.y + room.h):
        for x in range(room.x, room.x + room.w):
            if (
                y == room.y
                or y == room.y + room.h - 1
                or x == room.x
                or x == room.x + room.w - 1
            ):
                grid[y][x] = T_WALL
            else:
                grid[y][x] = T_FLOOR

def carve_tile(grid, x, y):
    if not (0 <= x < WIDTH and 0 <= y < HEIGHT):
        return

    if grid[y][x] == T_WALL:
        grid[y][x] = T_DOOR
    else:
        grid[y][x] = T_FLOOR

    # murs autour du couloir
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            nx = x + dx
            ny = y + dy

            if 0 <= nx < WIDTH and 0 <= ny < HEIGHT:
                if grid[ny][nx] == T_EMPTY:
                    grid[ny][nx] = T_WALL

def carve_horizontal(grid, x1, x2, y):
    for x in range(min(x1, x2), max(x1, x2) + 1):
        carve_tile(grid, x, y)

def carve_vertical(grid, y1, y2, x):
    for y in range(min(y1, y2), max(y1, y2) + 1):
        carve_tile(grid, x, y)

def create_corridor(grid, x1, y1, x2, y2):
    if random.choice([True, False]):
        carve_horizontal(grid, x1, x2, y1)
        carve_vertical(grid, y1, y2, x2)
    else:
        carve_vertical(grid, y1, y2, x1)
        carve_horizontal(grid, x1, x2, y2)

def random_floor_position(room):
    x = random.randint(room.x + 2, room.x + room.w - 3)
    y = random.randint(room.y + 2, room.y + room.h - 3)
    return x, y

def generate_level(max_rooms=8):
    grid = create_empty_map()
    rooms = []

    for _ in range(max_rooms * 6):

        # tailles x2 (surface x4)
        base_w = random.randint(10, 18)
        base_h = random.randint(6, 10)

        w = base_w * 2
        h = base_h * 2

        x = random.randint(3, WIDTH - w - 4)
        y = random.randint(3, HEIGHT - h - 4)

        new_room = Room(x, y, w, h)

        if any(new_room.intersects(room) for room in rooms):
            continue

        create_room(grid, new_room)

        if rooms:
            x1, y1 = rooms[-1].center()
            x2, y2 = new_room.center()
            create_corridor(grid, x1, y1, x2, y2)

        rooms.append(new_room)

        if len(rooms) >= max_rooms:
            break

    entities = []

    if rooms:
        sx, sy = random_floor_position(rooms[0])
        grid[sy][sx] = "S"

        ex, ey = random_floor_position(rooms[-1])
        grid[ey][ex] = ">"

        entities.append({
            "type": "player_start",
            "x": sx,
            "y": sy
        })

    return {
        "width": WIDTH,
        "height": HEIGHT,
        "tiles": ["".join(row) for row in grid],
        "rooms": [
            {"x": r.x, "y": r.y, "w": r.w, "h": r.h}
            for r in rooms
        ],
        "entities": entities
    }

def print_level(level):
    for row in level["tiles"]:
        print(row)

def save_level_txt(level, filename="level_001.txt"):
    with open(filename, "w", encoding="utf-8") as f:
        for row in level["tiles"]:
            f.write(row + "\n")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="level_001", help="Basename for output files (sans extension)")
    parser.add_argument("--seed",   type=int, default=None, help="Random seed for reproducibility")
    args = parser.parse_args()

    if args.seed is not None:
        random.seed(args.seed)

    level = generate_level()

    txt_file  = args.output + ".txt"
    json_file = args.output + ".json"

    # Export JSON
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(level, f, indent=2, ensure_ascii=False)

    # Export TXT
    save_level_txt(level, txt_file)

    print("TXT  : " + txt_file)
    print("JSON : " + json_file)
