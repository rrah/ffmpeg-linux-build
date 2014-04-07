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
	wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
	tar xzvf yasm-1.2.0.tar.gz
	cd yasm-1.2.0
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
	make
	make install
	make distclean
	export "PATH=$PATH:$HOME/bin"
	cd ../
}


build_x264() {
	wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
	tar xjvf last_x264.tar.bz2
	cd x264-snapshot*
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
	make
	make install
	make distclean
	cd ../
}

build_fdk_aac() {
	wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
	unzip fdk-aac.zip
	cd mstorsjo-fdk-aac*
	autoreconf -fiv
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean
	cd ../
}


build_rtmp() {
	git clone git://git.ffmpeg.org/rtmpdump
	cd rtmpdump
	make
	sudo checkinstall --pkgname=rtmpdump --pkgversion="2:$(date +%Y%m%d%H%M)-git" --backup=no \
    --deldoc=yes --fstrans=no --default
	cd ../
}


build_ffmpeg () {
	cd ffmpeg_sources
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
	tar xjvf ffmpeg-snapshot.tar.bz2
	cd ffmpeg
	PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
	export PKG_CONFIG_PATH
	./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" \
	   --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl \
	   --enable-libfdk-aac --enable-libx264 --enable-nonfree --enable-librtmp
	make
	make install
	make distclean
	hash -r
}

main(){
	check_missing_packages
	mkdir ffmpeg_sources
	build_yasm
	build_x264
	build_rtmp
	build_fdk_aac
	build_ffmpeg
	echo "Binaries are in somewhere"
	
}

main
