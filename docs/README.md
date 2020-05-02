# Making Sphinx Documentation

## installing packages

Install Sphinx, recommonmark, and optionally (for the RTD-styling), sphinx_rtd_theme,
preferably in a virtualenv:

```bash
pip install -U Sphinx recommonmark sphinx-rtd-theme
```

## setup docs

```bash
mkdir docs
cd docs
sphinx-quickstart
```

Make a index.rst file to create a table of contents directory

```rst
.. toctree::
   :maxdepth: 2

   usage/installation
   usage/quickstart
```

## compiling docs

Compile documentation with:

```bash
sphinx-build -E -W -b html . _build
```
or
```bash
make html
```

## viewing sphinx docs

- Install [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) in the vscode marketplace, or equivalent.

- In *"docs/_build"* right-click **index.html**, and select *Open with Live Server*.

## Docstrings

You can employ help from external packages to help you make docstrings in your python files. First install [autoDocString](https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring) from the vscode maketplace, or equivalent. In the configuration settings change "AutoDocstring: **Docstring Format**" to *sphinx*. To autofill a doctring under *def*, *class*, or *module* start a docstring (""") and press enter.

To help with autodocumenting python files read the [Sphinx Autodoc Guide](http://www.sphinx-doc.org/en/master/usage/extensions/autodoc.html), or the [Example pypi project](https://pythonhosted.org/an_example_pypi_project/sphinx.html).

## ReST

- Include full python code in doc

```rest
.. literalinclude:: <python file>
    :caption: caption text
    :linenos:
```

- Auto create document for python module

```rest
.. automodule:: <module name>
    :undoc-members:  # Do not include class/function members
    |or|
    :members: # include class/function members
```

- tables from csv files can be created. [csv-table](https://docutils.sourceforge.io/docs/ref/rst/directives.html#csv-table)

```rest
.. csv-table:: Frozen Delights!
   :header: "Treat", "Quantity", "Description"
   :widths: 15, 10, 30

   "Albatross", 2.99, "On a stick!"
   "Crunchy Frog", 1.49, "If we took the bones out, it wouldn't be
   crunchy, now would it?"
   "Gannet Ripple", 1.99, "On a stick!"
```

- superscript, subscript are envoked with:

```rest
\:sup:`2`\ or \:sub:`2`\
```

- abreviations can be made like:

```rest
.. |H2O| replace:: H\ :sub:`2`\ O
```

- you can add a file full of all the substitutions with an include
at the top of the file.

```rest
.. include:: ./substitution.rst
```

- Use a heading without including it in the toctree

```rest
.. raw:: html

   <h2>Index</h2>
```

- reference a variables

```rest
``self.scanObject.ZMat``
```

## References

For linking documentation with github and readthedocs:

- [Official Sphinx Documentation](http://www.sphinx-doc.org/en/master/index.html)
- [adafruit tutorial](https://learn.adafruit.com/creating-and-sharing-a-circuitpython-library/sharing-our-docs-on-readthedocs)
- [Getting Started Guide](https://docs.readthedocs.io/en/stable/intro/getting-started-with-sphinx.html)
- [Sphinx Autodoc Guide](http://www.sphinx-doc.org/en/master/usage/extensions/autodoc.html)

Syntax formats:

- https://thomas-cokelaer.info/tutorials/sphinx/rest_syntax.html
- https://www.sphinx-doc.org/en/2.0/usage/restructuredtext/basics.html
- https://rest-sphinx-memo.readthedocs.io/en/latest/ReST.html
- http://www.sphinx-doc.org/en/master/usage/restructuredtext/index.html
- https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

math & plotting in sphinx:

- https://matplotlib.org/sampledoc/

For viewing .rst files on the fly:

- [restview](https://pypi.org/project/restview/)

Auto docstring generator vscode extension:

- [autoDocString](https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring)

Liver Server to view sphinx html for vscode:

- [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)

