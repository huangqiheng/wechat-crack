AUTOMAKE_OPTIONS=foreign
bin_PROGRAMS=daemon
daemon_SOURCES=daemon-main.c

AM_CFLAGS =  `i686-w64-mingw32.static-pkg-config --cflags libcurl` 
AM_LDFLAGS = `i686-w64-mingw32.static-pkg-config --libs libcurl`
