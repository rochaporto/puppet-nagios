# Class defining a nagios target (a machine to be monitored).
#
# In a nagios NRPE setup, these are the machines which the main nagios host
# will contact and fetch monitoring data.
#
# The base probes are all here, but you can of course add additional ones.
# 
# == Examples
#
# Simply include this class, as in:
#   include nagios::target
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class nagios::target {

  package { ["nrpe", "nagios-plugins-all", "nagios-plugins-nrpe"]: ensure => latest, }

  service { "nrpe":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    subscribe  => File["/etc/nagios/nrpe.cfg"],
  }

  file { "/etc/nagios/nrpe.cfg":
    mode    => "0644",
    owner   => root,
    group   => root,
    notify  => Service["nrpe"],
    content => template("nagios/nrpe.cfg"),
  }

  @@nagios_host { $fqdn:
    ensure                => present,
    alias                 => $hostname,
    address               => $ipaddress,
    max_check_attempts    => 5,
    check_period          => 24x7,
    contact_groups        => "localadmins",
    notification_interval => 30,
    notification_period   => 24x7,
  }

  @@nagios_service { "check_load_${hostname}":
    ensure                => "present",
    host_name             => "$fqdn",
    max_check_attempts    => 5,
    check_period          => 24x7,
    contact_groups        => "localadmins",
    notification_interval => 30,
    notification_period   => 24x7,
    service_description   => "Load check for host: ${hostname}",
  }

}
