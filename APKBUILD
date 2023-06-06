# Reference: <https://postmarketos.org/vendorkernel>
# Kernel config based on: arch/arm64/configs/tucana_defconfig

pkgname=linux-xiaomi-tucana
pkgver=4.14.299
pkgrel=0
pkgdesc="Xiaomi Note 10 Pro kernel fork"
arch="aarch64"
_carch="arm64"
_flavor="xiaomi-tucana"
url="https://kernel.org"
license="GPL-2.0-only"
options="!strip !check !tracedeps pmb:cross-native"
makedepends="
	bash
	bc
	bison
	devicepkg-dev
	findutils
	flex
	linux-headers
	openssl-dev
	perl
	clang
	llvm
	lld
	xz
"

# Source
_repository="kernel_xiaomi_sm6150"
_commit="065292e26b718647b372480204baf9328ba2a72d"
_config="config-$_flavor.$arch"
source="
	$pkgname-$_commit.tar.gz::https://github.com/erikdrozina/$_repository/archive/$_commit.tar.gz
	$_config
"
builddir="$srcdir/$_repository-$_commit"
_outdir="out"

CC="clang"
HOSTCC="clang"

prepare() {
	default_prepare
	REPLACE_GCCH=0 . downstreamkernel_prepare
}

build() {
	unset LDFLAGS
	make O="$_outdir" \
		ARCH="$_carch" \
		CC=clang \
		CROSS_COMPILE=aarch64-alpine-linux-musl- \
		CROSS_COMPILE_ARM32=armv7-alpine-linux-musleabihf- \
		NM=llvm-nm \
		OBJCOPY=llvm-objcopy \
		OBJDUMP=llvm-objdump \
		STRIP=llvm-strip \
		LD=ld.lld \
		KBUILD_BUILD_VERSION="$((pkgrel + 1 ))-postmarketOS"
}

package() {
	downstreamkernel_package "$builddir" "$pkgdir" "$_carch" \
		"$_flavor" "$_outdir"
}

sha512sums="
b600140857f1cdf83615508f9f65ac97a86b18c314c55b967859ae745f3febf20d59e25499a2facceb54a6bc30b980850424f9fb087fc60697dc9ce132d2a9df  linux-xiaomi-tucana-065292e26b718647b372480204baf9328ba2a72d.tar.gz
9a9f4ef606641efbf302a979e5f2d4265d27184c3ce077e9326f1896e256406f8bb3911e5f74f6a710ee9eebb440a2e1984e928cba01a8688abf41b3d3d603e3  config-xiaomi-tucana.aarch64
"
