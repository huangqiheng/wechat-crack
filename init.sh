#!/bin/sh

#configure parameters
full_package_name=daemon
version=0.1
bug_report_address=and@hqh.me
share_name=share
script_path=`dirname $(readlink -f $0)`

#configure mode
echo "#------------------------------------------------------#"
echo "#////////////// enter generate conf mode //////////////#"
if [ "$1" = "conf" ]; then
	cd $script_path/src
	autoscan
	mv configure.scan configure.ac
	sed -i "s|FULL-PACKAGE-NAME|$full_package_name|g" configure.ac
	sed -i "s|VERSION|$version|g" configure.ac
	sed -i "s|BUG-REPORT-ADDRESS|$bug_report_address|g" configure.ac
	sed -i "s|AC_CONFIG_HEADERS|AM_INIT_AUTOMAKE\nAC_CONFIG_HEADERS|g" configure.ac

	aclocal
	autoconf
	autoheader
	automake --add-missing
	./configure --host=i686-w64-mingw32.static
	exit
fi

#make mode
echo "#------------------------------------------------------#"
echo "#////////////////// enter make mode ///////////////////#"
if [ "$1" = "make" ]; then
	cd $script_path/src
	make clean
	cflags=`curl-config --cflgs`
	./configure --host=i686-w64-mingw32.static
	make
	mv daemon.exe ../bin
	exit
fi

echo "#------------------------------------------------------#"
echo "#///////////////// clone my repository ////////////////#"

proj_path=$script_path

if [ ! -f $proj_path/README.md ]; then
	git clone https://github.com/huangqiheng/wechat-crack.git
	proj_path=$proj_path/wechat-crack
fi

echo "#------------------------------------------------------#"
echo "#///////////// MXE mingw-w64 Environment   ////////////#"
echo "#------------------------------------------------------#"
#http://mxe.cc/#requirements

apt-get update
apt-get install -y build-essential
apt-get install -y \
    autoconf automake autopoint bash bison bzip2 flex gettext\
    git g++ gperf intltool libffi-dev libgdk-pixbuf2.0-dev \
    libtool libltdl-dev libssl-dev libxml-parser-perl make \
    openssl p7zip-full patch perl pkg-config python ruby scons \
    sed unzip wget xz-utils
apt-get install -y g++-multilib libc6-dev-i386
apt-get install -y libtool-bin

echo "#------------------------------------------------------#"
echo "#/////////////// mount output directory ///////////////#"
echo "#------------------------------------------------------#"

share_out=$proj_path/bin

apt-get install -y virtualbox-guest-dkms

if [ ! -d $share_out ]; then
	mkdir -p $share_out
	mount -t vboxsf $share_name $share_out
fi

echo "#------------------------------------------------------#"
echo "#////////////// Download Install MXE  /////////////////#"
echo "#------------------------------------------------------#"
#http://mxe.cc/#usage

mxe_path=/opt/mxe

if [ ! -d $mxe_path ]; then
	cd /opt
	git clone https://github.com/mxe/mxe.git
fi

cd $mxe_path
#make gcc MXE_TARGETS='x86_64-w64-mingw32.static i686-w64-mingw32.static'
#http://mxe.cc/build-matrix.html
make gcc libwebsockets json-c curl protobuf MXE_TARGETS='i686-w64-mingw32.static'


#set mxe Envirorment Variables
bashrc=$HOME/.bashrc
mxe_bin=$mxe_path/usr/bin
pkcfg=$mxe_path/usr/i686-w64-mingw32.static/lib/pkgconfig
i686_bin=$mxe_path/usr/i686-w64-mingw32.static/bin

if ! grep -q "$mxe_bin" $bashrc
then
	echo "export PATH=$PATH:$mxe_bin:$i686_bin" >> $bashrc
	echo "export PKG_CONFIG_PATH_i686_w64_mingw32_static=$pkcfg" >> $bashrc
	echo "mount -t vboxsf $share_name $share_out" >> $bashrc
	echo "Update .bashrc file"
else
	echo "Already has environment varibales"
fi

exec bash
exit
