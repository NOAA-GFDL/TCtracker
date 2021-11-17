import jinja2
import os

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
    with open(file, "a") as f:
        f.write("\n".join(array + ['&\n']))
