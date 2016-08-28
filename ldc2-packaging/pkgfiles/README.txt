This is a standalone (DMD-style) binary package for LDC,
the LLVM-based D compiler.

No installation is required, simply use the executables
bin\ldc2.exe and/or bin\ldmd2.exe.
Just make sure you have a Microsoft Visual C++ 2015
installation for linking, either via Visual Studio 2015 or
via the stand-alone Visual C++ Build Tools, both freely
available from Microsoft.

The compiler configuration file is etc\ldc2.conf, and by
default only include\d resp. include\d\ldc are in the
module search path.

The LDC package is portable and should be able to detect
your Visual C++ installation automatically. By setting the
LDC_VSDIR environment variable to your VS/VC folder, you
can instruct LDC to detect a specific Visual C++
installation.

NOTE: Running LDC inside a 'VS Tools Command Prompt' is
      deprecated.

The Visual C++ detection is skipped when running LDC in a
'VS Native/Cross Tools Command Prompt' (i.e., if the
environment variable VSINSTALLDIR is set). Linking will
thus be restricted to the selected target.

DUB

DUB 1.0 works seamlessly together with LDC. If you have
different D compilers installed then you need to use the
--compiler=ldc2 option with DUB.
In order to avoid a dependency on the VS 2015 runtime, you
can add the following linker flags to your dub.json file:

"lflags-windows-ldc": [
        "libcmt.lib",
        "/nodefaultlib:msvcrt.lib",
        "/nodefaultlib:vcruntime.lib"
    ],

For further information, including on how to report bugs,
please refer to the LDC wiki: http://wiki.dlang.org/LDC.
