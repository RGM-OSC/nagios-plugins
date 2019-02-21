%define __perl_requires /bin/false
%define _prefix /srv/eyesofnetwork/nagios/
%define _libexecdir %{_prefix}/plugins
%define npusr nagios
%define npgrp eyesofnetwork

Name: nagios-plugins
Version: 2.1.4
Release: 0.rgm
Summary: Host/service/network monitoring program plugins for Nagios

Group: Applications/System
License: GPL
URL: http://nagiosplug.sourceforge.net/
Source0: http://dl.sf.net/sourceforge/nagiosplug/%{name}-%{version}.tar.gz
Source1: %{name}-rgm.tar.gz
Source2: %{name}-snmp-0.6.0.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%define npdir %{_builddir}/%{name}-%{version}

Prefix: %{_libexecdir}
Provides: nagios-plugins

%{!?custom:%global custom 0}
Obsoletes: nagios-plugins-custom nagios-plugins-extras


# Requires
Requires:	nagios
Requires:	bind-utils
Requires:	coreutils
Requires:	fping 
Requires:	gawk
Requires:	grep
Requires:	iputils
Requires:	mysql
Requires:	net-snmp-utils
Requires:	ntp
Requires:	openldap
Requires:	openssl
Requires:	openssh-clients
Requires:	perl, perl-libwww-perl-old, perl-LWP-Protocol-https, perl-Mail-Sendmail, perl-Module-Load, perl-Nagios-Plugin, perl-Time-Duration
Requires:	postgresql-libs
Requires:	procps
Requires:	python
Requires:	samba-client
Requires:	shadow-utils
Requires:	traceroute
Requires:	/usr/bin/mailq
BuildRequires:	bind-utils
BuildRequires:	coreutils
BuildRequires:	iputils
BuildRequires:	mysql-devel
BuildRequires:	net-snmp-utils
BuildRequires:	net-tools
BuildRequires:	ntp
BuildRequires:	openldap-devel
BuildRequires:	openssh-clients
BuildRequires:	openssl-devel
BuildRequires:	postgresql-devel
BuildRequires:	procps
BuildRequires:	samba-client
BuildRequires:	/usr/bin/mailq


%description

Nagios is a program that will monitor hosts and services on your
network, and to email or page you when a problem arises or is
resolved. Nagios runs on a unix server as a background or daemon
process, intermittently running checks on various services that you
specify. The actual service checks are performed by separate "plugin"
programs which return the status of the checks to Nagios. This package
contains those plugins.


%prep
%setup -q
%setup -D -T -a 1
%setup -D -T -a 2


%build
./configure \
--prefix=%{_prefix} \
--exec-prefix=%{_exec_prefix} \
--libexecdir=%{_libexecdir} \
--datadir=%{_datadir} \
--with-cgiurl=/nagios/cgi-bin
ls -1 %{npdir}/plugins > %{npdir}/ls-plugins-before
ls -1 %{npdir}/plugins-root > %{npdir}/ls-plugins-root-before
ls -1 %{npdir}/plugins-scripts > %{npdir}/ls-plugins-scripts-before
make %{?_smp_mflags}
ls -1 %{npdir}/plugins > %{npdir}/ls-plugins-after
ls -1 %{npdir}/plugins-root > %{npdir}/ls-plugins-root-after
ls -1 %{npdir}/plugins-scripts > %{npdir}/ls-plugins-scripts-after

%install
rm -rf $RPM_BUILD_ROOT
make AM_INSTALL_PROGRAM_FLAGS="" DESTDIR=${RPM_BUILD_ROOT} install
%{__install} -Dp -m0644 plugins-scripts/utils.pm ${RPM_BUILD_ROOT}%{perl_vendorlib}/utils.pm
build-aux/install-sh -c  -m 664 plugins/libnpcommon.a ${RPM_BUILD_ROOT}%{_libexecdir}
%find_lang %{name}
echo "%defattr(755,%{npusr},%{npgrp})" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-before %{npdir}/ls-plugins-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%defattr(755,root,root)" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-root-before %{npdir}/ls-plugins-root-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%defattr(755,%{npusr},%{npgrp})" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-scripts-before %{npdir}/ls-plugins-scripts-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%{_libexecdir}/utils.pm" >> %{name}.lang
echo "%{_libexecdir}/utils.sh" >> %{name}.lang

# CONTRIB Plugins
cd %{name}-eon
cp -aprf * ${RPM_BUILD_ROOT}%{_libexecdir}/

# SNMP C-Plugins
cd ../%{name}-snmp
./configure \
--prefix=%{_prefix} \
--exec-prefix=%{_libexecdir}/ \
--libexecdir=%{_libexecdir}/ \
--sysconfdir=%{_prefix}/etc \
--datadir=%{_prefix}/share
make %{?_smp_mflags}
make AM_INSTALL_PROGRAM_FLAGS="" DESTDIR=${RPM_BUILD_ROOT} install

%clean
rm -rf $RPM_BUILD_ROOT


%files -f %{name}.lang
%doc CODING COPYING FAQ INSTALL LEGAL README REQUIREMENTS SUPPORT THANKS
%doc ChangeLog
%{_prefix}/share/locale/de/LC_MESSAGES/nagios-plugins.mo
%{_prefix}/share/locale/fr/LC_MESSAGES/nagios-plugins.mo
%defattr(775,%{npusr},%{npgrp})
%{_libexecdir}/*
%{_prefix}/share/locale
%{perl_vendorlib}/utils.pm


%changelog
* Thu Feb 21 2019 Michael Aubertin <maubertin@fr.scc.com> - 2.1.4-1.rgm
- Initial fork

* Thu Jan 19 2017 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.1.4-0.eon
- upgrade to version 2.1.4

* Tue Sep 29 2015 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.1.1-0.eon
- upgrade to version 2.1.1

* Mon May 12 2014 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.0.1-0.eon
- upgrade to version 2.0.1

* Tue Mar 06 2014 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.0-0.eon
- packaged for EyesOfNetwork appliance 4.1

* Mon May 23 2005 Sean Finney <seanius@seanius.net> - cvs head
- just include the nagios plugins directory, which will automatically include
  all generated plugins (which keeps the build from failing on systems that
  don't have all build-dependencies for every plugin)
* Tue Mar 04 2004 Karl DeBisschop <karl[AT]debisschop.net> - 1.4.0alpha1
- extensive rewrite to facilitate processing into various distro-compatible specs
* Tue Mar 04 2004 Karl DeBisschop <karl[AT]debisschop.net> - 1.4.0alpha1
- extensive rewrite to facilitate processing into various distro-compatible specs
