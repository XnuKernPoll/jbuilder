***********
Terminology
***********

-  **package**: a package is a set of libraries, executables, ... that
   are built and installed as one by opam

-  **project**: a project is a source tree, maybe containing one or more
   packages

-  **root**: the root is the directory from where Jbuilder can build
   things. Jbuilder knows how to build targets that are descendents of
   the root. Anything outside of the tree starting from the root is
   considered part of the **installed world**. How the root is
   determined is explained in :ref:`finding-root`.

-  **workspace**: the workspace is the subtree starting from the root.
   It can contain any number of projects that will be built
   simultaneously by jbuilder

-  **installed world**: anything outside of the workspace, that Jbuilder
   takes for granted and doesn't know how to build

-  **installation**: this is the action of copying build artifacts or
   other files from the ``<root>/_build`` directory to the installed
   world

-  **scope**: a scope determines where private items are
   visible. Private items include libraries or binaries that will not
   be installed. In Jbuilder, scopes are sub-trees rooted where at
   least one ``<package>.opam`` file is present. Moreover, scopes are
   exclusive. Typically, every project defines a single scope. See
   :ref:`scopes` for more details

-  **build context**: a build context is a subdirectory of the
   ``<root>/_build`` directory. It contains all the build artifacts of
   the workspace built against a specific configuration. Without
   specific configuration from the user, there is always a ``default``
   build context, which corresponds to the environment in which Jbuilder
   is executed. Build contexts can be specified by writing a
   :ref:`jbuild-workspace` file

-  **build context root**: the root of a build context named ``foo`` is
   ``<root>/_build/<foo>``

-  **alias**: an alias is a build target that doesn't produce any file
   and has configurable dependencies. Alias are per-directory and some
   are recursive; asking an alias to be built in a given directory will
   trigger the construction of the alias in all children directories
   recursively. The most interesting ones are:

   -  ``runtest`` which runs user defined tests
   -  ``install`` which depends on everything that should be installed
   -  ``doc``     which depends on the generated HTML
      documentation. See :ref:`apidoc` for details
