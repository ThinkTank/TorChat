#!/bin/bash -e
# Build a debian package.
VERSION="$(git describe)"
DEB_FILE="torchat-${VERSION}.deb"
TORCHAT_DIR="$( readlink -f "$( dirname "${PWD}/${BASH_SOURCE}" )/.." )"

source "${TORCHAT_DIR}"/packaging/changelog.sh

tmpdir="$(mktemp -d)"
for d in "DEBIAN" "usr" "usr/bin" "usr/share" "usr/share/doc"\
	"usr/share/doc/torchat" "usr/share/doc/torchat/html" "usr/share/applications"\
	"usr/share/pixmaps" "usr/share/pixmaps/torchat" "usr/share/torchat" \
	"usr/share/torchat/SocksiPy" "usr/share/torchat/translations"\
	"usr/share/torchat/Tor"; do
	mkdir "${tmpdir}/${d}"
done

cp "${TORCHAT_DIR}"/packaging/debian/* "${tmpdir}/DEBIAN"
	mv "${tmpdir}/DEBIAN/torchat.desktop" "${tmpdir}/usr/share/applications"
cp "${TORCHAT_DIR}"/translations/*.{py,txt}\
	"${tmpdir}/usr/share/torchat/translations"
cp "${TORCHAT_DIR}"/icons/* "${tmpdir}/usr/share/pixmaps/torchat"
cp "${TORCHAT_DIR}"/SocksiPy/{__init__.py,socks.py,BUGS,LICENSE,README}\
	"${tmpdir}/usr/share/torchat/SocksiPy"
cp "${TORCHAT_DIR}"/Tor/{torrc.txt,tor.sh} "${tmpdir}/usr/share/torchat/Tor"
cp "${TORCHAT_DIR}"/*.py "${tmpdir}/usr/share/torchat/"
changelog > "${tmpdir}/usr/share/doc/torchat/changelog.txt"

sed -i -e "s/TORCHAT_VERSION/${VERSION}/" "${tmpdir}/DEBIAN/control"

fakeroot dpkg -b "$tmpdir" "$DEB_FILE"
rm -rf "$tmpdir"
