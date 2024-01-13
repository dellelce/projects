from os import environ


class savedirs:
    def __init__(self):
        """Interface to the old "shell-format" database."""
        self.home = environ.get("HOME")
        self.savedirs = environ.get("SAVEDIRS", f"{self.home}/.src/savedirs")
