%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: Caffeinated packet analyzer
Name: dripcap
Version: {{DRIPCAP_VERSION}}
Release: 1
License: MIT
Requires(post): libcap
AutoReqProv: no

%description
Dripcap is a modern packet analyzer based on Electron.

%prep

%build

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}
cp -a * %{buildroot}

%clean

%files
%defattr(-,root,root)
%doc

/usr/share/dripcap/
/usr/share/applications/dripcap.desktop
/usr/share/doc/dripcap/copyright
/usr/share/icons/hicolor/256x256/apps/dripcap.png
/usr/share/lintian/overrides/dripcap


%changelog

%post
setcap cap_net_raw,cap_net_admin=eip /usr/share/dripcap/dripcap
