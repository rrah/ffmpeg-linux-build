# packages: libssl-dev checkinstall autoconf automake build-essential libass-dev libgpac-dev libsdl1.2-dev libtool libva-dev libvdpau-dev pkg-config texi2html zlib1g-dev git unzip

check_missing_packages () {
  local check_packages=('checkinstall' 'autoconf' 'automake' 'libtool' 'pkg-config' 'texi2html' 'git' 'unzip')
  for package in "${check_packages[@]}"; do
    type -P "$package" >/dev/null || missing_packages=("$package" "${missing_packages[@]}")
  done

  if [[ -n "${missing_packages[@]}" ]]; then
    clear
    echo "Could not find the following execs (svn is actually package subversion, makeinfo is actually package texinfo if you're missing them): ${missing_packages[@]}"
    echo 'Install the missing packages before running this script.'
    exit 1
  fi
}

build_yasm() {
	cd /tmp/ffmpeg_source
	wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
	tar xzvf yasm-1.2.0.tar.gz
	cd yasm-1.2.0
	./configure --prefix="/usr/local" --bindir="/usr/local/bin"
	make
	make install
	make distclean
	export "PATH=$PATH:/usr/bin"
	cd /tmp/ffmpeg_source
}


build_x264() {
	cd /tmp/ffmpeg_source	
	wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
	tar xjvf last_x264.tar.bz2
	cd x264-snapshot*
	./configure --prefix="/usr/local/" --bindir="/usr/local/bin" --enable-static
	make
	make install
	make distclean
	cd /tmp/ffmpeg_source
}

build_fdk_aac() {
	cd /tmp/ffmpeg_source
	wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
	unzip fdk-aac.zip
	cd mstorsjo-fdk-aac*
	autoreconf -fiv
	./configure --prefix="/usr/local/" --disable-shared
	make
	make install
	make distclean
	cd /tmp/ffmpeg_source
}


build_rtmp() {
	cd /tmp/ffmpeg_source
	git clone git://git.ffmpeg.org/rtmpdump
	cd rtmpdump
	make
	sudo checkinstall --pkgname=rtmpdump --pkgversion="2:$(date +%Y%m%d%H%M)-git" --backup=no \
    --deldoc=yes --fstrans=no --default
	cd /tmp/ffmpeg_source
}


build_ffmpeg () {
	cd /tmp/ffmpeg_source
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
	tar xjvf ffmpeg-snapshot.tar.bz2
	cd ffmpeg
#	PKG_CONFIG_PATH="/tmp/ffmpeg_build/lib/pkgconfig"
#	export PKG_CONFIG_PATH
	./configure --prefix="/usr/local/" --extra-cflags="-I/usr/local/include" \
	   --extra-ldflags="-L/usr/local/lib, -Wl,-rpath,/usr/local/lib" --bindir="/usr/local/bin" --extra-libs="-ldl" --enable-gpl \
	   --enable-libfdk-aac --enable-libx264 --enable-nonfree --enable-librtmp
	make
	make install
	make distclean
	hash -r
}

main(){
	check_missing_packages
	mkdir /tmp/ffmpeg_source
	cd /tmp/ffmpeg_source
	build_yasm
	build_x264
	build_rtmp
	build_fdk_aac
	build_ffmpeg
	echo "Binaries are installed to /usr/local/bin/"
	
}

main
