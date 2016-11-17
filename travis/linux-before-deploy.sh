chmod -R g-w debian
gulp out
gulp debian
rm -r .debian/usr/share/dripcap
mv .builtapp/Dripcap-linux-x64 .debian/usr/share/dripcap
mv .debian/usr/share/dripcap/Dripcap .debian/usr/share/dripcap/dripcap
cd .debian
chrpath -r /usr/share/dripcap ./usr/share/dripcap/dripcap
fakeroot dpkg-deb --build . ../dripcap-linux-amd64.deb
cd ..

# rpm
mkdir -p ~/rpm/SPECS
mkdir -p ~/rpm/SOURCES
mkdir -p ~/rpm/BUILD
mkdir -p ~/rpm/RPMS
mkdir -p ~/rpm/SRPMS

DRIPVER=$(jq -r '.version' package.json)
sed -e "s/{{DRIPCAP_VERSION}}/$DRIPVER/g" dripcap.rpm.spec > ~/rpm/dripcap.rpm.spec

cat <<EOF >~/.rpmmacros
%_topdir   %(echo $HOME)/rpm
EOF

cp -r .debian/usr ~/rpm/BUILD
rpmbuild -bb ~/rpm/dripcap.rpm.spec
mv ~/rpm/RPMS/*/*.rpm dripcap-linux-amd64.rpm
