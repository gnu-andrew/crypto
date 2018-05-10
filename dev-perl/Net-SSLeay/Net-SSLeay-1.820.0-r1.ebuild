# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DIST_AUTHOR=MIKEM
DIST_VERSION=1.82
DIST_EXAMPLES=("examples/*")
inherit flag-o-matic multilib perl-module

DESCRIPTION="Perl extension for using OpenSSL"
SRC_URI="${SRC_URI}
	http://fuseyism.com/patches/${PN}-openssl-1.1.0-updated-constants.patch"

LICENSE="openssl"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl test minimal examples"

RDEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	virtual/perl-MIME-Base64
"
DEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? (
		!minimal? (
			dev-perl/Test-Exception
			dev-perl/Test-Warn
			dev-perl/Test-NoWarnings
		)
		virtual/perl-Test-Simple
	)
"
export OPTIMIZE="$CFLAGS"
export OPENSSL_PREFIX=${EPREFIX}/usr

PATCHES=(
	"${FILESDIR}/${PN}-1.82-respect-cflags.patch"
	"${FILESDIR}/${PN}-1.82-fix-libdir.patch"
	"${FILESDIR}/${PN}-1.82-fix-network-tests.patch"
	"${FILESDIR}/${PN}-openssl-1.1.0.patch"
	"${DISTDIR}/${PN}-openssl-1.1.0-updated-constants.patch"
)

src_prepare() {
	use test && perl_rm_files 't/local/01_pod.t' 't/local/02_pod_coverage.t' 't/local/kwalitee.t'
	perl-module_src_prepare
}

src_configure() {
	if use test && has network ${DIST_TEST_OVERRIDE:-${DIST_TEST:-do parallel}}; then
		export NETWORK_TESTS=yes
	else
		use test && einfo "Network tests will be skipped without DIST_TEST_OVERRIDE=~network"
		export NETWORK_TESTS=no
	fi
	export LIBDIR=$(get_libdir)
	append-cflags "-Werror=implicit-function-declaration"
	perl-module_src_configure
}
