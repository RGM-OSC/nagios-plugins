%define __perl_requires /bin/false
%define _prefix %{rgm_path}/nagios
%define _libexecdir %{_prefix}/plugins

Name: nagios-plugins
Version: 2.2.1
Release: 1.rgm
Summary: Host/service/network monitoring program plugins for Nagios

Group: Applications/System
License: GPL
URL: https://nagios-plugins.org/
Source0: https://nagios-plugins.org/download/%{name}-%{version}.tar.gz

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%define npdir %{_builddir}/%{name}-%{version}
%define src_nrpe nrpe-nrpe-4.1.0

Source1: %{src_nrpe}.tar.gz
Patch0: nagios-plugins-check_ping.patch


Prefix: %{_libexecdir}
Provides: nagios-plugins

%{!?custom:%global custom 0}
Obsoletes: nagios-plugins-custom nagios-plugins-extras


### {rgm_user_nagios} -g %{rgm_group}

# Requires
Requires: bind-utils
Requires: gawk
Requires: grep
Requires: iputils
Requires: openldap
Requires: mariadb
Requires: openssl
Requires: postgresql-libs
Requires: nagios
Requires: net-snmp-utils
Requires: ntpstat
Requires: openssh-clients
Requires: perl
Requires: procps
Requires: python
Requires: samba-client
Requires: coreutils
Requires: shadow-utils
Requires: traceroute
Requires: esmtp
BuildRequires: rpm-macros-rgm
BuildRequires: bind-utils
BuildRequires: iputils
BuildRequires: mariadb-devel
BuildRequires: net-snmp-utils
BuildRequires: net-tools
BuildRequires: ntpstat
BuildRequires: openldap-devel
BuildRequires: openssh-clients
BuildRequires: openssl-devel
BuildRequires: postgresql-devel
BuildRequires: procps
BuildRequires: samba-client
BuildRequires: coreutils
BuildRequires: esmtp


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
%patch0 -p1

%setup -D -a 1


%build
# build nagios-plugins
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

#build nagios nrpe plugin
cd %{src_nrpe}
./configure \
    --enable-command-args \
    --enable-bash-command-substitution \
    --libexecdir=/srv/rgm/nagios/plugins \
    --prefix=/srv/rgm/nrpe \
    --with-nrpe-port=5666 \
    --with-nagios-user=nagios \
    --with-nagios-group=rgm
make check_nrpe
cd -


%install
rm -rf $RPM_BUILD_ROOT
make AM_INSTALL_PROGRAM_FLAGS="" DESTDIR=${RPM_BUILD_ROOT} install
%{__install} -Dp -m0644 plugins-scripts/utils.pm ${RPM_BUILD_ROOT}%{perl_vendorlib}/utils.pm
build-aux/install-sh -c  -m 664 plugins/libnpcommon.a ${RPM_BUILD_ROOT}%{_libexecdir}
%find_lang %{name}
echo "%defattr(755,%{rgm_user_nagios},%{rgm_group})" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-before %{npdir}/ls-plugins-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%defattr(755,root,root)" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-root-before %{npdir}/ls-plugins-root-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%defattr(755,%{rgm_user_nagios},%{rgm_group})" >> %{name}.lang
comm -13 %{npdir}/ls-plugins-scripts-before %{npdir}/ls-plugins-scripts-after | egrep -v "\.o$|^\." | gawk -v libexecdir=%{_libexecdir} '{printf( "%s/%s\n", libexecdir, $0);}' >> %{name}.lang
echo "%{_libexecdir}/utils.pm" >> %{name}.lang
echo "%{_libexecdir}/utils.sh" >> %{name}.lang

# NRPE plugin
install -m 0755 -o %{rgm_user_nagios} -g %{rgm_group} %{src_nrpe}/src/check_nrpe  %{buildroot}%{rgm_path}/nagios/plugins/


%clean
rm -rf $RPM_BUILD_ROOT


%files -f %{name}.lang
%doc CODING COPYING FAQ INSTALL LEGAL README REQUIREMENTS SUPPORT THANKS
%doc ChangeLog
%{_prefix}/share/locale/de/LC_MESSAGES/nagios-plugins.mo
%{_prefix}/share/locale/fr/LC_MESSAGES/nagios-plugins.mo
%defattr(775,%{rgm_user_nagios},%{rgm_group})
%{_libexecdir}/*
%{_prefix}/share/locale
%{perl_vendorlib}/utils.pm


%changelog
* Thu Oct 22 2020 Eric Belhomme <ebelhomme@fr.scc.com> - 2.2.1-1.rgm
- add Nagios NRPE plugin 4.0.2

* Mon Apr 08 2019 Eric Belhomme <ebelhomme@fr.scc.com> - 2.2.1-0.rgm
- upgraded nagios-plugins to latest release (2.2.1)
- moved RGM additional plugins into nagios-plugins-rgm package

* Fri Apr 05 2019 Eric Belhomme <ebelhomme@fr.scc.com> - 2.1.4-2.rgm
- patch check_ping to remove perfdata when RTA is over critical value

* Thu Feb 21 2019 Michael Aubertin <maubertin@fr.scc.com> - 2.1.4-1.rgm
- Initial fork

* Thu Jan 19 2017 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.1.4-0.eon
- upgrade to version 2.1.4

* Tue Sep 29 2015 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.1.1-0.eon
- upgrade to version 2.1.1

* Mon May 12 2014 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.0.1-0.eon
- upgrade to version 2.0.1

* Thu Mar 06 2014 Jean-Philippe Levy <jeanphilippe.levy@gmail.com> - 2.0-0.eon
- packaged for EyesOfNetwork appliance 4.1

* Mon May 23 2005 Sean Finney <seanius@seanius.net> - cvs head
- just include the nagios plugins directory, which will automatically include
  all generated plugins (which keeps the build from failing on systems that
  don't have all build-dependencies for every plugin)

* Thu Mar 04 2004 Karl DeBisschop <karl[AT]debisschop.net> - 1.4.0alpha1
- extensive rewrite to facilitate processing into various distro-compatible specs

* Thu Mar 04 2004 Karl DeBisschop <karl[AT]debisschop.net> - 1.4.0alpha1
- extensive rewrite to facilitate processing into various distro-compatible specs
