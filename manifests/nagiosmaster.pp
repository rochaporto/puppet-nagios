# Class defining the nagios main host.
#
# This is the host where the nagios daemon will run, which collects the
# monitoring information from the targets and also hosts the webserver.
# 
# == Examples
#
# Simply include this class, as in:
#  include nagios::master
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class nagios::master {

  package { ["nagios", "nagios-plugins-all", "nagios-plugins-nrpe"]: ensure => latest, }

  #
  # TODO: move httpd (package, service, files) to its own module
  # 
  package { "httpd": ensure => latest, }

  service { "httpd":
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  file {
    "/etc/httpd/conf.d/nagios.conf":
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/nagios-httpd.conf"),
      notify  => Service["httpd"],
      require => Package["httpd"];
    "/etc/nagios/cgi.cfg":
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/cgi.cfg"),
      notify  => Service["httpd"],
      require => Package["httpd"];
  }

  service { "nagios":
    ensure => running,
    enable => true,
    subscribe => File["conf-nagios"],
    require => Package["nagios"],
  }

  exec { "nagios-fixperms":
    command     => "/bin/chmod -R 755 /etc/nagios/*",
    notify      => Service["nagios"],
  }

  file { 
    "conf-nagios":
      ensure  => present,
      name    => "/etc/nagios/nagios.cfg",
      mode    => "0644",
      owner   => root,
      group   => root,
      notify  => Service["nagios"],
      content => template("nagios/nagios.cfg");
    "conf-nagios-servers":
      ensure  => directory,
      name    => "/etc/nagios/servers",
      mode    => "0644",
      owner   => root,
      group   => root;
  }

  Nagios_command {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/commands.cfg",
  }

  Nagios_contact {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/contacts.cfg",
  }

  Nagios_contactgroup {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/contactgroups.cfg",
  }

  Nagios_host {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/hosts.cfg",
  }

  Nagios_hostgroup {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/hostgroups.cfg",
  }

  Nagios_service {
    notify => Exec["nagios-fixperms"],
  }

  Nagios_servicegroup {
    notify => Exec["nagios-fixperms"],
    target => "/etc/nagios/servicegroups.cfg",
  }

  @@nagios_command { 
    "check_ping":
      ensure        => "present",
      command_line => "\$USER1\$/check_ping -H \$HOSTADDRESS$ -w \$ARG1$ -c \$ARG2$";
    "check_nrpe":
      ensure        => "present",
      command_line => "\$USER1\$/check_nrpe -H \$HOSTADDRESS$ -c \$ARG1$ -a \$ARG2$";
  }

  @@nagios_contact { "nagios":
    ensure                        => present,
    alias                         => "Nagios Admin",
    host_notification_period      => "24x7",
    service_notification_period   => "24x7",
    service_notification_options  => "w,u,c,r",
    host_notification_options     => "d,u,r",
    service_notification_commands => "notify-by-email",
    host_notification_commands    => "host-notify-by-email",
    email                         => "ricardo.rocha@cern.ch",
  }

  @@nagios_contactgroup { "localadmins":
    alias   => "Local site admins",
    members => "nagios",
  }

  Nagios_command <<||>>
  Nagios_contact <<||>>
  Nagios_contactgroup <<||>>
  Nagios_host <<||>>
  Nagios_hostgroup <<||>>
  Nagios_service <<||>>
  Nagios_servicegroup <<||>>

}
