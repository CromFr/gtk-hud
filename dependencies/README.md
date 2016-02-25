
Lua version 5.1 (required for LuaD)
================================================================================

### Linux
```sh
cd lua
./build.sh
cd ..

ln -s dependencies/lua/lua-5.1.5/lib/liblua.so ..
```

### Windows
You'd better download pre-compiled binaries


LuaFileSystem
================================================================================

Provides file/dir functions for LUA

### Linux
```sh
cd luafilesystem
make PREFIX=$PWD/../lua/lua-5.1.5/
cd ..

ln -s dependencies/luafilesystem/src/lfs.so ..
```

### Windows 64bit
with Visual Studio 2013 installed:
```bat
cd luafilesystem
<!-- "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall amd64" -->
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\vcvars64.bat"
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\cl" /c /Fosrc\lfs.obj /MD /O2 /I"C:\Program Files\Lua\include" src\lfs.c
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\link" /dll /def:src\lfs.def /out:src\lfs.dll src\lfs.obj "C:\Program Files\Lua\lua5.1.lib"
```