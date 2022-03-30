# Author: Collin Koss
# GitHub username: Roamingturtl
# Date: 3/2/2022
# Description: Contains code to play a 'Battleship' style game where the class ShipGame and Ship hold all the
# necessary methods and data members required to play the game. Game state is initialized to starting values with
# the ShipGame class.  place_ships then fire_torpedo until a player sinks all their opponents ships!  Turns alternate
# after a player fires a torpedo starting with P1.


class ShipGame:
    """
    Acts as a game object that contains and maintains the gamestate and methods required for playing a battleship
    style game.
    """

    def __init__(self):
        """
        Initializes starting gamestate.
        """

        self._p1_ships = []
        self._p2_ships = []
        self._p1_grid = [['-'] * 10 for _ in range(10)]
        self._p2_grid = [['-'] * 10 for _ in range(10)]
        self._active_player = "first"
        self._current_state = "UNFINISHED"


    def place_ship(self, player, length, coord, orientation):
        """
        Takes a player, ship length, coordinate, and orientation as parameters for placing a new ship on the board.

        :param player: Which players is placing the ship.
        :param length: How many spaces the ship takes up.
        :param coord: The coordinate it will occupy closest to the top left space.
        :param orientation: Either 'R' or 'C' for occupying the same row or column as the coord.
        :return: True is valid placement, else False for invalid placement.
        """

        if coord[0] > 'J':
            return False
        if len(coord) > 3:
            return False
        if int(coord[1:]) > 10:
            return False
        if length < 2:
            return False

        if player == 'first':
            grid = self._p1_grid
            player_ships = self._p1_ships
        elif player == 'second':
            grid = self._p2_grid
            player_ships = self._p2_ships
        else:
            return False

        # Check for ship overlap on player grid.
        row, column = self._translate_coordinate(coord)
        if orientation == 'R':
            if column + length - 1 > 9:
                return False
            for temp_column in range(column, (column + length)):            # Check 'R'
                if grid[row][temp_column] != '-':
                    return False
        elif orientation == 'C':
            if row + length - 1 > 9:
                return False
            for temp_row in range(row, (row + length)):                     # Check 'C'
                if grid[temp_row][column] != '-':
                    return False

        # Place ship on player grid.
        new_ship = Ship(length)
        player_ships.append(new_ship)
        for _ in range(length):
            if orientation == 'R':                                          # Place 'R'
                grid[row][column] = new_ship
                column += 1
            elif orientation == 'C':                                        # Place 'C'
                grid[row][column] = new_ship
                row += 1
        return True


    def fire_torpedo(self, player, coord):
        """
        Takes the player firing the torpedo and the coordinate it's targeting as parameters.  If the player parameter
        does not equal the active player return False.  Otherwise records move, updates active player, updates
        game state, and return True. Records move by changing the value of the target coordinate to 'X' for a ship
        hit, or 'M' for a miss.  If the target coordinate value was an object calls hit_ship from the Ship class and
        decrements length counter.  If length then equals 0 removes the ship from enemy_ships. Then checks game state
        for a winner referencing enemy_player's ship list.
        :param player: Player attempting the action.
        :param coord: target coordinate; must be in LetterNumber format eg. 'B7'.
        :return: False if player is not active player, True otherwise.
        """

        if self._active_player != player:
            return False
        elif self._current_state != "UNFINISHED":
            return False

        if player == 'first':
            grid = self._p2_grid
            enemy_ships = self._p2_ships
            self._active_player = 'second'
        elif player == 'second':
            grid = self._p1_grid
            enemy_ships = self._p1_ships
            self._active_player = 'first'
        else:
            return False

        # Fire successful torpedo, update data.
        row, column = self._translate_coordinate(coord)
        target = grid[row][column]
        if isinstance(target, Ship):
            target._hit_ship()
            grid[row][column] = 'X'
            if target.get_length() == 0:
                enemy_ships.remove(target)
                if len(enemy_ships) == 0:
                    self._current_state = player.upper() + "_WON"
        else:
            grid[row][column] = 'M'
        return True


    def _translate_coordinate(self, coord):
        """
        Takes the coordinate entered when calling place_ship and fire_torpedo, and translates it into a tuple to be
        unpacked and used to navigate the grid to the proper space.
        :param coord: Coordinate parameter in LetterNumber format eg. B1
        :return: tuple row, column
        """

        alphabet_key = {
            "A" : 0, "B" : 1, "C" : 2, "D" : 3, "E" : 4, "F" : 5, "G" : 6, "H" : 7, "I" : 8, "J" : 9
        }
        row = alphabet_key[coord[0]]
        if 0 <= 2 < len(coord):
            return row, 9
        column = int(coord[1]) - 1
        return row, column


    def get_current_state(self):
        """Returns current_state"""
        return self._current_state


    def get_num_ships_remaining(self, player):
        """
        Returns the number of ships remaining for the player passed in the parameter.
        :param player: takes "first" or "second".
        :return: _p1_ships or _p2_ships respective of parameter.
        """
        if player == "first":
            return len(self._p1_ships)
        else:
            return len(self._p2_ships)


class Ship:
    """
    Ship object class that contains all the data for a ship including ownership, length, position, and orientation.
    Used by the place_ship method and fire_torpedo from ShipGame class.
    """


    def __init__(self, length):
        """
        Initializes values to create and place a new ship with.
        :param length: how many spaces on the grid ship occupies
        """
        self._length = length


    def get_length(self):
        return self._length


    def _hit_ship(self):
        """Decreases the length counter of an existing ship to indicate remaining health"""
        self._length = self._length - 1

