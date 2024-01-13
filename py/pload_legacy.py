"""cli.pload test with lagecy class."""

from sys import argv

from cli import pload

from legacy import projects


def main(name: str) -> None:
    """Test pload for specified name."""
    p = projects()

    print("; ".join(pload(p, name)))


if __name__ == "__main__":
    main(argv[1])
