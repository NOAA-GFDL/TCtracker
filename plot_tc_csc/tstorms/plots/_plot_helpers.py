import jinja2
import os

"""Helper functions and variables for Grace plots

Variables:

    - template_env -- Jinja2 template environment
"""

__all__ = [
    'template_env',
    'write_plot_data'
]
_dir = os.path.join(os.path.dirname(__file__), 'templates')
template_env = jinja2.Environment(loader=jinja2.FileSystemLoader(_dir))
template_env.keep_trailing_newline = True
template_env.trim_blocks = True
template_env.lstrip_blocks = True
template_env.rstrip_blocks = True


def write_plot_data(file, array):
    """Write Grace plot data to file

    Generates (or appends) data from array to file.  `array` should contain
    strings as elements.  `write_plot_data` will add a `&` after last array
    element.  This is needed for Grace.

    Keyword Arguments:

        - file -- File to write/append to.
        - array -- array of strings.
    """
    with open(file, "a") as f:
        f.write("\n".join(array + ['&\n']))
