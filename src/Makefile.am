AUTOMAKE_OPTIONS=foreign
bin_PROGRAMS=daemon
daemon_SOURCES=daemon-main.c
lib=/opt/mxe/usr/i686-w64-mingw32.static/lib
daemon_LDADD=$(lib)/libcurl.a $(lib)/libssh2.a $(lib)/libgcrypt.a $(lib)/libgpg-error.a $(lib)/libgnutls.a $(lib)/libhogweed.a $(lib)/libnettle.a $(lib)/libidn.a $(lib)/libcrypt32.a $(lib)/libgmp.a $(lib)/libintl.a $(lib)/libiconv.a $(lib)/libwldap32.a $(lib)/libz.a $(lib)/libws2_32.a 

AM_CFLAGS=$(shell i686-w64-mingw32.static-pkg-config --cflags libcurl)
AM_LDFLAGS=$(shell i686-w64-mingw32.static-pkg-config --libs libcurl)

