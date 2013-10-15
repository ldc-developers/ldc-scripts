This is a standalone (DMD-style) binary package for LDC,
the LLVM-based D compiler.

No installation is required. Just make sure that the system
linker (i.e., gcc) is on the executable search path when
running the compiler.

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


[1] http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/rubenvb/gcc-4.8-dw2-release/i686-w64-mingw32-gcc-dw2-4.8.0-win32_rubenvb.7z/download