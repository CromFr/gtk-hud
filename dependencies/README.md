
# Build luafilesystem on Windoze 64bit

with Visual Studio 2013 installed:
```
<!-- "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall amd64" -->
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\vcvars64.bat"
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\cl" /c /Fosrc\lfs.obj /MD /O2 /I"C:\Program Files\Lua\include" src\lfs.c
"C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64\link" /dll /def:src\lfs.def /out:src\lfs.dll src\lfs.obj "C:\Program Files\Lua\lua5.1.lib"
```