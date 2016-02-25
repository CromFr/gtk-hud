#!/bin/bash
LUAVERSION=5.1.5

# wget http://www.lua.org/ftp/lua-$LUAVERSION.tar.gz
# tar xf lua-$LUAVERSION.tar.gz

cd lua-$LUAVERSION
make CFLAGS="-O2 -Wall \$(MYCFLAGS) -fPIC" linux
make CFLAGS="-O2 -Wall \$(MYCFLAGS) -fPIC" local


# Build shared library
gcc -shared -o lib/liblua.so \
	src/{lapi.o,lcode.o,ldebug.o,ldo.o,ldump.o,lfunc.o,lgc.o,llex.o,lmem.o,lobject.o,lopcodes.o,lparser.o,lstate.o,lstring.o,ltable.o,ltm.o,lundump.o,lvm.o,lzio.o,lauxlib.o,lbaselib.o,ldblib.o,liolib.o,lmathlib.o,loslib.o,ltablib.o,lstrlib.o,loadlib.o,linit.o}

cd ..