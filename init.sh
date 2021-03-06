#!/bin/sh


#configure parameters
share_name=share
mxe_path=/opt/mxe
i686_prefix=$mxe_path/usr/i686-w64-mingw32.static
script_path=`dirname $(readlink -f $0)`


#make mode
echo "#------------------------------------------------------#"
echo "#////////////////// enter make mode ///////////////////#"
if [ "$1" = "make" ]; then
	cd $script_path
	aclocal
	autoconf
	automake --add-missing
	make clean
	./configure --host=i686-w64-mingw32.static
	#./configure --libdir $(i686_prefix)/lib --exec-prefix $(i686_prefix) --host=i686-w64-mingw32.static
	#./configure --exec-prefix $i686_prefix --host=i686-w64-mingw32.static
	make
	#mv daemon.exe ../bin
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
apt-get install smartmontools

is_vmware=$(smartctl --all /dev/sda1 | grep -i vmware 2>&1)

if [ $is_vmware ]; then
	echo "vmware"
else 
	apt-get install -y virtualbox-guest-dkms

	mkdir -p $share_out
	mount -t vboxsf $share_name $share_out
fi

echo "#------------------------------------------------------#"
echo "#////////////// Download Install MXE  /////////////////#"
echo "#------------------------------------------------------#"
#http://mxe.cc/#usage

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
i686_bin=$i686_prefix/bin

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
