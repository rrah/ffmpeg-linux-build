# packages: libssl-dev checkinstall autoconf automake build-essential libass-dev libgpac-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libx11-dev libxext-dev libxfixes-dev pkg-config texi2html zlib1g-dev git unzip libsdl1.2-dev libva-dev libvdpau-dev libx11-dev libxext-dev libxfixes-dev

build_yasm() {
	cd ~/ffmpeg_sources
	wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
	tar xzvf yasm-1.2.0.tar.gz
	cd yasm-1.2.0
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
	make
	make install
	make distclean
	export "PATH=$PATH:$HOME/bin"
}


build_x264() {
	cd ~/ffmpeg_sources
	wget http://download.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
	tar xjvf last_x264.tar.bz2
	cd x264-snapshot*
	./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static
	make
	make install
	make distclean
}

build_fdk_aac() {
	cd ~/ffmpeg_sources
	wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master
	unzip fdk-aac.zip
	cd mstorsjo-fdk-aac*
	autoreconf -fiv
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared
	make
	make install
	make distclean
}


build_rtmp() {
	cd ~/ffmpeg_sources
	git clone git://git.ffmpeg.org/rtmpdump
	cd rtmpdump
	make
	sudo checkinstall --pkgname=rtmpdump --pkgversion="2:$(date +%Y%m%d%H%M)-git" --backup=no \
    --deldoc=yes --fstrans=no --default
}


build_ffmpeg () {
	cd ~/ffmpeg_sources
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
	tar xjvf ffmpeg-snapshot.tar.bz2
	cd ffmpeg
	PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig"
	export PKG_CONFIG_PATH
	./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" \
	   --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl \
	   --enable-libfdk-aac --enable-libx264 --enable-nonfree --enable-librtmp --enable-x11grab
	make
	make install
	make distclean
	hash -r
}

main(){
	mkdir ~/ffmpeg_sources
	build_yasm
	build_x264
	build_rtmp
	build_fdk_aac
	build_ffmpeg
}

main
