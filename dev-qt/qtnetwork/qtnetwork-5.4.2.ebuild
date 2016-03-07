# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-qt/qtnetwork/qtnetwork-5.4.2.ebuild,v 1.1 2015/06/17 15:21:41 pesa Exp $

EAPI=5
QT5_MODULE="qtbase"
inherit qt5-build

DESCRIPTION="Network abstraction library for the Qt5 framework"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64"
fi

IUSE="bindist connman networkmanager +ssl"

DEPEND="
	~dev-qt/qtcore-${PV}
	>=sys-libs/zlib-1.2.5
	connman? ( ~dev-qt/qtdbus-${PV} )
	networkmanager? ( ~dev-qt/qtdbus-${PV} )
	ssl? ( dev-libs/openssl:0[bindist=] )
"
RDEPEND="${DEPEND}
	connman? ( net-misc/connman )
	networkmanager? ( net-misc/networkmanager )
"

PATCHES=(
	"${FILESDIR}/${PN}-5.4-aes256.patch"
)

QT5_TARGET_SUBDIRS=(
	src/network
	src/plugins/bearer/generic
)

QT5_GENTOO_CONFIG=(
	ssl::SSL
	ssl::OPENSSL
	ssl:openssl-linked:LINKED_OPENSSL
)

pkg_setup() {
	use connman && QT5_TARGET_SUBDIRS+=(src/plugins/bearer/connman)
	use networkmanager && QT5_TARGET_SUBDIRS+=(src/plugins/bearer/networkmanager)
}

src_configure() {
	local myconf=(
		$(use connman || use networkmanager && echo -dbus-linked)
		$(use ssl && echo -openssl-linked)
	)
	qt5-build_src_configure
}
