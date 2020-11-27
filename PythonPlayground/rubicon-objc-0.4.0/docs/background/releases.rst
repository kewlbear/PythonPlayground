Release History
===============

.. towncrier release notes start

0.4.0 (2020-07-04)
------------------

Features
^^^^^^^^

* Added macOS 10.15 (Catalina) to the test matrix.
  (`#145 <https://github.com/beeware/rubicon-objc/issues/145>`_)
* Added :pep:`517` and :pep:`518` build system metadata to pyproject.toml.
  (`#156 <https://github.com/beeware/rubicon-objc/issues/156>`_)
* Added official support for Python 3.8.
  (`#162 <https://github.com/beeware/rubicon-objc/issues/162>`_)
* Added a ``varargs`` keyword argument to
  :func:`~rubicon.objc.runtime.send_message` to allow calling variadic methods
  more safely. (`#174 <https://github.com/beeware/rubicon-objc/issues/174>`_)
* Changed ``ObjCMethod`` to call methods using
  :func:`~rubicon.objc.runtime.send_message` instead of calling
  :class:`~rubicon.objc.runtime.IMP`\s directly. This is mainly an internal
  change and should not affect most existing code, although it may improve
  compatibility with Objective-C code that makes heavy use of runtime
  reflection and method manipulation (such as swizzling).
  (`#177 <https://github.com/beeware/rubicon-objc/issues/177>`_)

Bugfixes
^^^^^^^^

* Fixed Objective-C method calls in "flat" syntax accepting more arguments than
  the method has. The extra arguments were previously silently ignored.
  An exception is now raised if too many arguments are passed.
  (`#123 <https://github.com/beeware/rubicon-objc/issues/123>`_)
* Fixed :func:`ObjCInstance.__str__ <rubicon.objc.api.ObjCInstance.__str__>`
  throwing an exception if the object's Objective-C ``description`` is ``nil``.
  (`#125 <https://github.com/beeware/rubicon-objc/issues/125>`_)
* Corrected a slow memory leak caused every time an asyncio timed event handler
  triggered. (`#146 <https://github.com/beeware/rubicon-objc/issues/146>`_)
* Fixed various minor issues in the build and packaging metadata.
  (`#156 <https://github.com/beeware/rubicon-objc/issues/156>`_)
* Removed unit test that attempted to pass a struct with bit fields into a C
  function by value. Although this has worked in the past on x86 and x86_64,
  :mod:`ctypes` never officially supported this, and started generating an
  error in Python 3.7.6 and 3.8.1
  (see `bpo-39295 <https://bugs.python.org/issue39295>`_).
  (`#157 <https://github.com/beeware/rubicon-objc/issues/157>`_)
* Corrected the invocation of ``NSApplication.terminate()`` when the
  :class:`~rubicon.objc.eventloop.CocoaLifecycle` is ended.
  (`#170 <https://github.com/beeware/rubicon-objc/issues/170>`_)
* Fixed :func:`~rubicon.objc.runtime.send_message` not accepting
  :class:`~rubicon.objc.runtime.SEL` objects for the ``selector`` parameter.
  The documentation stated that this is allowed, but actually doing so caused
  a type error. (`#177 <https://github.com/beeware/rubicon-objc/issues/177>`_)

Improved Documentation
^^^^^^^^^^^^^^^^^^^^^^

* Added detailed :doc:`reference documentation </reference/index>` for all
  public APIs of :mod:`rubicon.objc`.
  (`#118 <https://github.com/beeware/rubicon-objc/issues/118>`_)
* Added a :doc:`how-to guide for calling regular C functions
  </how-to/c-functions>` using :mod:`ctypes` and :mod:`rubicon.objc`.
  (`#147 <https://github.com/beeware/rubicon-objc/issues/147>`_)

Deprecations and Removals
^^^^^^^^^^^^^^^^^^^^^^^^^

* Removed the i386 architecture from the test matrix. It is still supported on
  a best-effort basis, but compatibility is not tested automatically.
  (`#139 <https://github.com/beeware/rubicon-objc/issues/139>`_)
* Tightened the API of :func:`~rubicon.objc.runtime.send_message`, removing
  some previously allowed shortcuts and features that were rarely used, or
  likely to be used by accident in an unsafe way.

  .. note::

      In most cases, Rubicon's high-level method call syntax provided by
      :class:`~rubicon.objc.api.ObjCInstance` can be used instead of
      :func:`~rubicon.objc.runtime.send_message`. This syntax is almost always
      more convenient to use, more readable and less error-prone.
      :func:`~rubicon.objc.runtime.send_message` should only be used in cases
      not supported by the high-level syntax.

* Disallowed passing class names as :class:`str`/:class:`bytes` as the
  ``receiver`` argument of :func:`~rubicon.objc.runtime.send_message`. If you
  need to send a message to a class object (i. e. call a class method), use
  :class:`~rubicon.objc.api.ObjCClass` or
  :func:`~rubicon.objc.runtime.get_class` to look up the class, and pass the
  resulting :class:`~rubicon.objc.api.ObjCClass` or
  :class:`~rubicon.objc.runtime.Class` object as the receiver.
* Disallowed passing :class:`~ctypes.c_void_p` objects as the ``receiver``
  argument of :func:`~rubicon.objc.runtime.send_message`. The ``receiver``
  argument now has to be of type :class:`~rubicon.objc.runtime.objc_id`, or
  one of its subclasses (such as :class:`~rubicon.objc.runtime.Class`), or one
  of its high-level equivalents
  (such as :class:`~rubicon.objc.api.ObjCInstance`). All Objective-C objects
  returned by Rubicon's high-level and low-level APIs have one of these types.
  If you need to send a message to an object pointer stored as
  :class:`~ctypes.c_void_p`, :func:`~ctypes.cast` it to
  :class:`~rubicon.objc.runtime.objc_id` first.
* Removed default values for :func:`~rubicon.objc.runtime.send_message`'s
  ``restype`` and ``argtypes`` keyword arguments. Every
  :func:`~rubicon.objc.runtime.send_message` call now needs to have its return
  and argument types set explicitly. This ensures that all arguments and the
  return value are converted correctly between (Objective-)C and Python.
* Disallowed passing more argument values than there are argument types in
  ``argtypes``. This was previously allowed to support calling variadic methods
  - any arguments beyond the types set in ``argtypes`` would be passed as
  varargs. However, this feature was easy to misuse by accident, as it allowed
  passing extra arguments to *any* method, even though most Objective-C methods
  are not variadic. Extra arguments passed this way were silently ignored
  without causing an error or a crash.

  To prevent accidentally passing too many arguments like this, the number of
  arguments now has to exactly match the number of ``argtypes``. Variadic
  methods can still be called, but the varargs now need to be passed as a list
  into the separate ``varargs`` keyword arugment.
  (`#174 <https://github.com/beeware/rubicon-objc/issues/174>`_)
* Removed the ``rubicon.objc.core_foundation`` module. This was an internal
  module with few remaining contents and should not have any external uses. If
  you need to call Core Foundation functions in your code, please load the
  framework yourself using ``load_library('CoreFoundation')`` and define the
  types and functions that you need.
  (`#175 <https://github.com/beeware/rubicon-objc/issues/175>`_)
* Removed the ``ObjCMethod`` class from the public API, as there was no good
  way to use it from external code.
  (`#177 <https://github.com/beeware/rubicon-objc/issues/177>`_)

Misc
^^^^

* `#143 <https://github.com/beeware/rubicon-objc/issues/143>`_,
  `#145 <https://github.com/beeware/rubicon-objc/issues/145>`_,
  `#155 <https://github.com/beeware/rubicon-objc/issues/155>`_,
  `#158 <https://github.com/beeware/rubicon-objc/issues/158>`_,
  `#159 <https://github.com/beeware/rubicon-objc/issues/159>`_,
  `#164 <https://github.com/beeware/rubicon-objc/issues/164>`_,
  `#173 <https://github.com/beeware/rubicon-objc/issues/173>`_,
  `#178 <https://github.com/beeware/rubicon-objc/issues/178>`_,
  `#179 <https://github.com/beeware/rubicon-objc/issues/179>`_


0.3.1
-----

* Added a workaround for `bpo-36880 <https://bugs.python.org/issue36880>`_,
  which caused a "deallocating None" crash when returning structs from methods
  very often.
* Added macOS High Sierra (10.13) and macOS Mojave (10.14) to the test matrix.
* Renamed the ``rubicon.objc.async`` module to ``rubicon.objc.eventloop`` to
  avoid conflicts with the Python 3.6 ``async`` keyword.
* Removed support for Python 3.4.
* Removed OS X Yosemite (10.10) from the test matrix. This version is (and
  older ones are) still supported on a best-effort basis, but compatibility is
  not tested automatically.

0.3.0
-----

* Added Pythonic operators and methods on ``NSString`` objects, similar to
  those for ``NSArray`` and ``NSDictionary``.
* Removed automatic conversion of ``NSString`` objects to ``str`` when returned
  from Objective-C methods. This feature made it difficult to call Objective-C
  methods on ``NSString`` objects, because there was no easy way to prevent the
  automatic conversion.

  In most cases, this change will not affect existing code, because
  ``NSString`` objects now support operations similar to ``str``. If an actual
  ``str`` object is required, the ``NSString`` object can be wrapped in a
  ``str`` call to convert it.
* Added support for ``objc_property``\s with non-object types.
* Added public ``get_ivar`` and ``set_ivar`` functions for manipulating ivars.
* Changed the implementation of ``objc_property`` to use ivars instead of
  Python attributes for storage. This fixes name conflicts in some situations.
* Added the :func:`~rubicon.objc.runtime.load_library` function for loading
  :class:`~ctypes.CDLL`\s by their name instead of their full path.
* Split the high-level Rubicon API (:class:`ObjCInstance`, :class:`ObjCClass`,
  etc.) out of :mod:`rubicon.objc.runtime` into a separate
  :mod:`rubicon.objc.api` module. The :mod:`~rubicon.objc.runtime` module now
  only contains low-level runtime interfaces like
  :data:`~rubicon.objc.runtime.libobjc`.

  This is mostly an internal change, existing code will not be affected unless
  it imports names directly from :mod:`rubicon.objc.runtime`.
* Moved :class:`~rubicon.objc.types.c_ptrdiff_t` from
  :mod:`rubicon.objc.runtime` to :mod:`rubicon.objc.types`.
* Removed some rarely used names (:class:`~rubicon.objc.runtime.IMP`,
  :class:`~rubicon.objc.runtime.Class`, :class:`~rubicon.objc.runtime.Ivar`,
  :class:`~rubicon.objc.runtime.Method`, :func:`~rubicon.objc.runtime.get_ivar`,
  :class:`~rubicon.objc.runtime.objc_id`,
  :class:`~rubicon.objc.runtime.objc_property_t`,
  :func:`~rubicon.objc.runtime.set_ivar`) from the main
  :mod:`rubicon.objc` namespace.

  If needed, these names can be imported explicitly from the
  :mod:`rubicon.objc.runtime` module.

* Fixed ``objc_property`` setters on non-macOS platforms. (cculianu)
* Fixed various bugs in the collection ``ObjCInstance`` subclasses:
* Fixed getting/setting/deleting items or slices with indices lower than
  ``-len(obj)``. Previously this crashed Python, now an ``IndexError`` is
  raised.
* Fixed slices with step size 0. Previously they were ignored and 1 was
  incorrectly used as the step size, now an ``IndexError`` is raised.
* Fixed equality checks between Objective-C arrays/dictionaries and
  non-sequence/mapping objects. Previously this incorrectly raised a
  ``TypeError``, now it returns ``False``.
* Fixed equality checks between Objective-C arrays and sequences of different
  lengths. Previously this incorrectly returned ``True`` if the shorter sequence
  was a prefix of the longer one, now ``False`` is returned.
* Fixed calling ``popitem`` on an empty Objective-C dictionary. Previously
  this crashed Python, now a ``KeyError`` is raised.
* Fixed calling ``update`` with both a mapping and keyword arguments on an
  Objective-C dictionary. Previously the kwargs were incorrectly ignored if a
  mapping was given, now both are respected.
* Fixed calling methods using kwarg syntax if a superclass and subclass define
  methods with the same prefix, but different names. For example, if a
  superclass had a method ``initWithFoo:bar:`` and the subclass
  ``initWithFoo:spam:``, the former could not be called on instances of the
  subclass.
* Fixed the internal ``ctypes_patch`` module so it no longer depends on a
  non-public CPython function.

0.2.10
------

* Rewrote almost all Core Foundation-based functions to use Foundation instead.

    * The functions ``from_value`` and ``NSDecimalNumber.from_decimal`` have
      been removed and replaced by ``ns_from_py``.
    * The function ``at`` is now an alias for ``ns_from_py``.
    * The function ``is_str`` has been removed. ``is_str(obj)`` calls should
      be replaced with ``isinstance(obj, NSString)``.
    * The functions ``to_list``, ``to_number``, ``to_set``, ``to_str``, and
      ``to_value`` have been removed and replaced by ``py_from_ns``.

* Fixed ``declare_property`` not applying to subclasses of the class it was
  called on.
* Fixed ``repr`` of ``ObjCBoundMethod`` when the wrapped method is not an
  ``ObjCMethod``.
* Fixed the encodings of ``NSPoint``, ``NSSize``, and ``NSRect`` on 32-bit
  systems.
* Renamed the ``async`` support package to ``eventloop`` to avoid a Python 3.5+
  keyword clash.

0.2.9
-----

* Improved handling of boolean types.
* Added support for using primitives as object values (e.g, as the key/value in
  an NSDictonary).
* Added support for passing Python lists as Objective-C NSArray arguments, and
  Python dicts as Objective-C NSDictionary arguments.
* Corrected support to storing strings and other objects as properties on
  Python-defined Objective-C classes.
* Added support for creating Objective-C blocks from Python callables. (ojii)
* Added support for returning compound values (structures and unions) from
  Objective-C methods defined in Python.
* Added support for creating, extending and conforming to Objective-C protocols.
* Added an ``objc_const`` convenience function to look up global Objective-C
  object constants in a DLL.
* Added support for registering custom ``ObjCInstance`` subclasses to be used
  to represent Objective-C objects of specific classes.
* Added support for integrating NSApplication and UIApplication event loops
  with Python's asyncio event loop.

0.2.8
-----

* Added support for using native Python sequence/mapping syntax with
  ``NSArray`` and ``NSDictionary``. (jeamland)
* Added support for calling Objective-C blocks in Python. (ojii)
* Added functions for declaring custom conversions between Objective-C type
  encodings and ``ctypes`` types.
* Added functions for splitting and decoding Objective-C method signature
  encodings.
* Added automatic conversion of Python sequences to C arrays or structures in
  method arguments.
* Extended the Objective-C type encoding decoder to support block types, bit
  fields (in structures), typed object pointers, and arbitrary qualifiers. If
  unknown pointer, array, struct or union types are encountered, they are
  created and registered on the fly.
* Changed the ``PyObjectEncoding`` to match the real definition of
  ``PyObject *``.
* Fixed the declaration of ``unichar`` (was previously ``c_wchar``, is now
  ``c_ushort``).
* Removed the ``get_selector`` function. Use the ``SEL`` constructor instead.
* Removed some runtime function declarations that are deprecated or unlikely to
  be useful.
* Removed the encoding constants. Use ``encoding_for_ctype`` to get the encoding
  of a type.

0.2.7
-----

* (#40) Added the ability to explicitly declare no-attribute methods as
  properties. This is to enable a workaround when Apple introduces readonly
  properties as a way to access these methods.

0.2.6
-----

* Added a more compact syntax for calling Objective-C methods, using Python
  keyword arguments. (The old syntax is still fully supported and will *not*
  be removed; certain method names even require the old syntax.)
* Added a ``superclass`` property to ``ObjCClass``.

0.2.5
-----

* Added official support for Python 3.6.
* Added keyword arguments to disable argument and/or return value conversion
  when calling an Objective-C method.
* Added support for (``NS``/``UI``) ``EdgeInsets`` structs. (Longhanks)
* Improved ``str`` of Objective-C classes and objects to return the
  ``debugDescription``, or for ``NSString``\s, the string value.
* Changed ``ObjCClass`` to extend ``ObjCInstance`` (in addition to ``type``),
  and added an ``ObjCMetaClass`` class to represent metaclasses.
* Fixed some issues on non-x86_64 architectures (i386, ARM32, ARM64).
* Fixed example code in README. (Dayof)
* Removed the last of the Python 2 compatibility code.

0.2.4
-----

* Added ``objc_property`` function for adding properties to custom Objective-C
  subclasses. (Longhanks)

0.2.3
-----

* Removed most Python 2 compatibility code.

0.2.2
-----

* Dropped support for Python 3.3.
* Added conversion of Python ``enum.Enum`` objects to their underlying values
  when passed to an Objective-C method.
* Added syntax highlighting to example code in README. (stsievert)
* Fixed the ``setup.py`` shebang line. (uranusjr)

0.2.1
-----

* Fixed setting of ``ObjCClass``/``ObjCInstance`` attributes that are not
  Objective-C properties.

0.2.0
-----

* First beta release.
* Dropped support for Python 2. Python 3 is now required, the minimum tested
  version is Python 3.3.
* Added error detection when attempting to create an Objective-C class with a
  name that is already in use.
* Added automatic conversion between Python ``decimal.Decimal`` and
  Objective-C ``NSDecimal`` in method arguments and return values.
* Added PyPy to the list of test platforms.
* When subclassing Objective-C classes, the return and argument types of
  methods are now specified using Python type annotation syntax and ``ctypes``
  types.
* Improved property support.

0.1.3
-----

* Fixed some issues on ARM64 (iOS 64-bit).

0.1.2
-----

* Fixed ``NSString`` conversion in a few situations.
* Fixed some issues on iOS and 32-bit platforms.

0.1.1
-----

* Objective-C classes can now be subclassed using Python class syntax, by
  using an ``ObjCClass`` as the superclass.
* Removed ``ObjCSubclass``, which is made obsolete by the new subclassing
  syntax.

0.1.0
-----

* Initial alpha release.
* Objective-C classes and instances can be accessed via ``ObjCClass`` and
  ``ObjCInstance``.
* Methods can be called on classes and instances with Python method call
  syntax.
* Properties can be read and written with Python attribute syntax.
* Method return and argument types are read automatically from the method
  type encoding.
* A small number of commonly used structs are supported as return and
  argument types.
* Python strings are automatically converted to and from ``NSString`` when
  passed to or returned from a method.
* Subclasses of Objective-C classes can be created with ``ObjCSubclass``.
