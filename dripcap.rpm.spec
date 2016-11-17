# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: Caffeinated packet analyzer
Name: dripcap
Version: {{DRIPCAP_VERSION}}
Release: 1
License: MIT
Requires(post): libcap

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

/usr/bin/dripcap
/usr/share/dripcap/

%changelog

%post
setcap cap_net_raw,cap_net_admin=eip /usr/share/dripcap/dripcap

