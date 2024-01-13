"""
Manage projects.

Created:      221119
"""

from __future__ import annotations

from os import scandir

from config import savedirs


class projects_iterator:
    """Iterator for projects."""

    def __init__(self: projects_iterator, projects: projects) -> None:
        self._projects = projects
        self._index = 0

    def __iter__(self: projects_iterator) -> projects_iterator:
        return self

    def __next__(self):
        if self._index >= len(self._projects):
            raise StopIteration
        else:
            item = self._projects.db[self._projects.db_l[self._index]]
            self._index += 1
            return item


class projects(savedirs):
    """Interface to shell-format database."""

    def __init__(self):
        super().__init__()

        self.db = {
            entry.name[: -len(".proj")]: self.project_json(
                f"{self.savedirs}/{entry.name}"
            )
            for entry in scandir(self.savedirs)
            if entry.is_file() and entry.name.endswith(".proj")
        }
        self.db_l = list(self.db)  # for use by the iterator

    def __len__(self):
        return len(self.db)

    def __iter__(self):
        return projects_iterator(self)

    def __getitem__(self, key):
        return self.db[key]

    def get(self, key, default=None):
        return self.db.get(key, default)

    def project_json(self, filename):
        """Load shell format project file into a dict."""
        proj_dict = {}

        with open(filename) as fh:
            raw_proj = fh.read().splitlines()
            for line in raw_proj:
                if "vim:syntax=sh" in line:
                    continue

                if "=" in line:
                    # this only works if there is a single "="
                    line_a = line.split("=")

                    value = line_a[1]

                    if value[0] == '"':
                        value = value[1:]

                    if value[-1] == '"':
                        value = value[0:-1]

                    proj_dict[line_a[0]] = value

        return proj_dict
