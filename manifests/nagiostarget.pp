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

  file { 
    "/etc/nagios/nrpe.cfg":
      mode    => "0644",
      owner   => root,
      group   => root,
      notify  => Service["nrpe"],
      content => template("nagios/nrpe.cfg");
    "/etc/nrpe.d":
      ensure => directory,
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/nrpe-generic.cfg"),
      notify  => Service["nrpe"];
    "/etc/nrpe.d/generic.cfg":
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/nrpe-generic.cfg"),
      notify  => Service["nrpe"],
      require => File["/etc/nrpe.d"];
  }

  Nagios_service {
    target => "/etc/nagios/servers/${hostname}.cfg",
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

  @@nagios_service { 
    "check_load_${fqdn}":
      ensure                => "present",
      host_name             => "$fqdn",
      service_description   => "Load for host: ${fqdn}",
      check_command         => "check_nrpe!check_load -a 0.6,0.6,0,6 0.9,0.9,0.9",
      max_check_attempts    => 5,
      normal_check_interval => 30,
      retry_check_interval  => 1,
      check_period          => 24x7,
      notification_interval => 120,
      notification_period   => 24x7,
      notification_options  => "w,u,c,r,f",
      contact_groups        => "localadmins",
  }

  @@nagios_service { 
    "check_ping_${fqdn}":
      ensure                => "present",
      host_name             => "$fqdn",
      service_description   => "Ping for host: ${fqdn}",
      check_command         => "check_ping!100.0,20%!500.0,60%",
      max_check_attempts    => 5,
      normal_check_interval => 30,
      retry_check_interval  => 1,
      check_period          => 24x7,
      notification_interval => 120,
      notification_period   => 24x7,
      notification_options  => "w,u,c,r,f",
      contact_groups        => "localadmins",
  }
}
