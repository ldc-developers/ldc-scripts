This is a standalone (DMD-style) binary package for LDC,
the LLVM-based D compiler.

No installation is required. Just make sure that the system
linker (i.e., gcc) is on the executable search path when
running the compiler.

NOTE: LDC on Windows with VisualStudio

LDC requires VS2015. To run the compiler you open the VS2015
x64 Native Tools Command Prompt (for 64bit) the VS2015 x86
Native Tools Command Prompt (for 32bit) and add LDC to the
search path. DUB 1.0 works seamless together with LDC. If
you have different D compilers installed then you need to
use the --compiler=ldc2 option with DUB.
In order to avoid a dependency on the VS 2015 runtime, you
cab add the following linker flags to your dub.json file:

"lflags-windows-ldc": [
        "libcmt.lib",
        "/nodefaultlib:msvcrt.lib",
        "/nodefaultlib:vcruntime.lib"
    ],


NOTE: The MinGW/Win32 port *REQUIRES* a *RECENT* mingw-w64
toolchain such as [1] (or newer). The reason for this are
severe bugs in the thread-local storage implementation; do
not expect GCC versions from earlier than Spring 2013
and/or from mingw.org to produce usable binaries. LDC
relies on DWARF 2-style (dw2) exception handling.

The compiler configuration file is etc/ldc2.conf, and by
default only import/ resp. import/ldc/ are on the module
search path.

For further information, including on how to report bugs,
please refer to the LDC wiki: http://wiki.dlang.org/LDC.


[1] http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/4.9.1/threads-posix/dwarf/i686-4.9.1-release-posix-dwarf-rt_v3-rev1.7z/download