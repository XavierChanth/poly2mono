from IPython.display import Image, display, SVG
from subprocess import run
from pydot import graph_from_dot_data
from re import sub

# A function which calls 'melos ls' in a subprocess
def melos_ls(args:list, ignore_example=True):
  if ignore_example:
    args += ['--ignore=*example*']
  result = run(['melos', 'ls', '-r'] + args, cwd='../', capture_output=True)
  print('Command run:', result.args)
  return result.stdout.decode('utf-8'), result.returncode == 0


def main():
  ##############################################################################
  # Graphviz format
  GV, GVsuccess = melos_ls(['--gviz'])

  # For some reason, melos outputs ";" inside the "[]"
  # instead of "," so we reformat with regex:
  GV = sub(r'(\[.*)(\;)(.*\])', r'\1,\3', GV)

  # Ensure that the subprocess was successful
  print(f'Success: {GVsuccess}')
  ##############################################################################
  should_write = True
  graphs = graph_from_dot_data(GV)
  plt = SVG(graphs[0].create(prog='dot', format='svg'))
  if should_write:
    with open('../docs/diagrams/package_tree_by_module.svg', 'w') as f:
      f.write(plt.data)
      f.close()
  ##############################################################################
  should_write = True

  # Remove subgraphs (module groupings)
  idx = GV.find('subgraph')
  GVH = GV[:idx]
  GVH += "}\n"

  graphs = graph_from_dot_data(GVH)
  plt = SVG(graphs[0].create(prog='dot', format='svg'))
  if should_write:
    with open('../docs/diagrams/package_tree_hierarchical.svg', 'w') as f:
      f.write(plt.data)
      f.close()
  ##############################################################################

if __name__ == '__main__':
  main()