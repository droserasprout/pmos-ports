# Reference: <https://postmarketos.org/vendorkernel>
# Kernel config based on: arch/arm64/configs/tucana_defconfig

pkgname=linux-xiaomi-tucana
pkgver=4.14.275
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
"

# Source
_repository="kernel_xiaomi_tucana"
_commit="a0c0618b7864248bd8369bdbb37b04571cf5f0fc"
_config="config-$_flavor.$arch"
source="
	$pkgname-$_commit.tar.gz::https://github.com/OctaviOS-Devices/$_repository/archive/$_commit.tar.gz
	$_config
"
builddir="$srcdir/$_repository-$_commit"
_outdir="out"

prepare() {
	default_prepare
	REPLACE_GCCH=0 . downstreamkernel_prepare
}

build() {
	unset LDFLAGS
	make O="$_outdir" ARCH="$_carch" CC="${CC:-gcc}" \
		KBUILD_BUILD_VERSION="$((pkgrel + 1 ))-postmarketOS"
}

package() {
	downstreamkernel_package "$builddir" "$pkgdir" "$_carch" \
		"$_flavor" "$_outdir"
}

sha512sums="
f4dc0bec0dfe9a2d4defb2d2298b0c5756fd22a6f0ab10766840ec3ca1dfbd6b2279ff6d9f8af4553024647e469e766ab174a2b4ecc9c2c6d78b58ca71fd3054  linux-xiaomi-tucana-a0c0618b7864248bd8369bdbb37b04571cf5f0fc.tar.gz
88dc7ffff07bfd169cea57f57fd7d7efdbe7fe84231f1fa3c11d80728b366334bd1a64143046e6060aa585cde5f373195480e920490673837d25532026cfa463  config-xiaomi-tucana.aarch64
"
