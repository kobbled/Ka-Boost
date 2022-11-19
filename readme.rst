*********
Ka-Boost
*********

This is repository of a collection of FANUC Karel libraries. 
Each package is formatted to work with the karel package manager 
rossum, and compiler wrapper ktransw.


Documentations
================

Install
================

.. _rossum: https://github.com/kobbled/rossum
.. _ktransw: https://github.com/kobbled/ktransw_py
.. _here: https://github.com/kobbled/rossum/releases
.. _TP-Plus: https://github.com/kobbled/tp_plus

* Install `rossum`_ (https://github.com/kobbled/rossum). Alternatively, a convenience distributions
  can be downloaded `here`_.

To install all of Ka-Boost's modules use:

.. code-block:: sh

    git clone https://github.com/kobbled/Ka-Boost --recurse-submodules

Add the path where this is stored to the environment variable **ROSSUM_PKG_PATH** to start using.

Getting Started
==================

.. _rossum_examples_ws: https://github.com/kobbled/rossum_example_ws

Try building the packages in `rossum_examples_ws`_ . If everything is install properly
these should build for you.
