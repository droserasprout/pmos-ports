# Reference: <https://postmarketos.org/vendorkernel>
# Kernel config based on: arch/arm64/configs/tucana_defconfig

pkgname=linux-xiaomi-tucana
pkgver=4.14.290
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
_repository="kernel_xiaomi_sm6150"
_commit="f77f0bd6f0831f0d9acf91691505a8e6313c13b3"
_config="config-$_flavor.$arch"
source="
	$pkgname-$_commit.tar.gz::https://github.com/erikdrozina/$_repository/archive/$_commit.tar.gz
	$_config
"
builddir="$srcdir/$_repository-$_commit"
_outdir="out"

prepare() {
	default_prepare
	REPLACE_GCCH=1 . downstreamkernel_prepare
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
b600140857f1cdf83615508f9f65ac97a86b18c314c55b967859ae745f3febf20d59e25499a2facceb54a6bc30b980850424f9fb087fc60697dc9ce132d2a9df  linux-xiaomi-tucana-065292e26b718647b372480204baf9328ba2a72d.tar.gz
30711627c17a7697797078e674046cbb9ed38c4177027ec2663340811848c80175367dd00966754beae108244c914b5c35c2fa12e058e18f96cab47d45b70bcb  config-xiaomi-tucana.aarch64
"
