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

  package { ["nagios", "nagios-plugins", "nagios-plugins-nrpe"]: ensure => latest, }

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

  file { "conf-nagios":
    ensure  => present,
    name    => "/etc/nagios/nagios.cfg",
    mode    => "0644",
    owner   => root,
    group   => root,
    notify  => Service["nagios"],
    content => template("nagios/nagios.cfg"),
  }

  Nagios_host {
    notify => Exec["nagios-fixperms"],
  }

  Nagios_service {
    notify => Exec["nagios-fixperms"],
  }

  Nagios_command {
    notify => Exec["nagios-fixperms"],
  }

  Nagios_contact {
    notify => Exec["nagios-fixperms"],
  }

  Nagios_contactgroup {
    notify => Exec["nagios-fixperms"],
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

  @@nagios_command { "check_nrpe":
    ensure        => "present",
    command_line => "check_nrpe -H \$HOSTADDRESS$ -p 5666 -c \$ARG1$",
  }

  Nagios_host <<||>>
  Nagios_service <<||>>
  Nagios_command <<||>>
  Nagios_contact <<||>>
  Nagios_contactgroup <<||>>

}
