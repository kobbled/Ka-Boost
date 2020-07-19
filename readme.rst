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
.. _here: https://github.com/kobbled/rossum/releases/tag/0.2.0
.. _TP-Plus: https://github.com/kobbled/tp_plus

In order to run Ka-Boost libraries, `rossum`_ and `ktransw`_ must be installed
properly with the nessecary environment variables set. A convenience distribution
has been made, which can be downloaded `here`_. Read the `rossum`_ readme for more information.
Make sure you add the location of this zip folder to your PATH! Also create the nessecary
environment variables specified in the `rossum`_ readme. If you are installing from source make 
sure you are using the kobbled master branch and not the upstream master root from gvanderhoorn.  

To install all of Ka-Boost's modules use:

.. code-block:: sh

    git clone https://github.com/kobbled/Ka-Boost --recurse-submodules

Add the path where this is stored to the environment variable **ROSSUM_PKG_PATH** to start using.

Some packages also ulitize `TP-Plus`_ instead of LS files. TP-Plus is written in ruby. To use this
language abstraction please install ruby, clone the repository, add to your path, and install by 
running the commands in the *Development* section of it's readme file.

Getting Started
==================

.. _rossum_examples_ws: https://github.com/kobbled/rossum_example_ws

Try building the packages in `rossum_examples_ws`_ . If everything is install properly
these should build for you.
