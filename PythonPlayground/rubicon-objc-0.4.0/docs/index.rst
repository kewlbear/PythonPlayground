.. raw:: html

    <style>
        .row {clear: both}

        .column img {border: 1px solid black;}

        @media only screen and (min-width: 1000px),
               only screen and (min-width: 500px) and (max-width: 768px){

            .column {
                padding-left: 5px;
                padding-right: 5px;
                float: left;
            }

            .column3  {
                width: 33.3%;
            }

            .column2  {
                width: 50%;
            }
        }
    </style>


===================
Rubicon Objective-C
===================

Rubicon Objective-C is a bridge between Objective-C and Python. It enables you
to:

* Use Python to instantiate objects defined in Objective-C,
* Use Python to invoke methods on objects defined in Objective-C, and
* Subclass and extend Objective-C classes in Python.

It also includes wrappers of the some key data types from the Foundation
framework (e.g., ``NSString``).

.. rst-class::  row

Table of contents
=================

.. rst-class:: clearfix row

.. rst-class:: column column2

:doc:`Tutorial <./tutorial/index>`
----------------------------------

Get started with a hands-on introduction for beginners


.. rst-class:: column column2

:doc:`How-to guides <./how-to/index>`
-------------------------------------

Guides and recipes for common problems and tasks, including how to contribute


.. rst-class:: column column2

:doc:`Background <./background/index>`
--------------------------------------

Explanation and discussion of key topics and concepts


.. rst-class:: column column2

:doc:`Reference <./reference/index>`
------------------------------------

Technical reference - commands, modules, classes, methods


.. rst-class:: clearfix row

Community
=========

Rubicon is part of the `BeeWare suite <https://beeware.org>`__. You can talk to the community through:

 * `@pybeeware on Twitter <https://twitter.com/pybeeware>`__

 * `beeware/general on Gitter <https://gitter.im/beeware/general>`_


.. toctree::
   :maxdepth: 2
   :hidden:
   :titlesonly:

   tutorial/index
   how-to/index
   background/index
   reference/index
