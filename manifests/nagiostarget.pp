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
class nagios::target inherits nagios {

  $nrpe_path="\$PATH:/opt/edg/bin:/opt/glite/bin:/opt/lcg/bin:/opt/globus/bin:/opt/lcg/lib/nagios/plugins/lcgdm:/opt/lcg/lib64/nagios/plugins/lcgdm"
  $nrpe_python_path="\$PYTHONPATH:/opt/lcg/lib64/python2.4/site-packages"

  package { ["xinetd", "nrpe", "nagios-plugins-all", "nagios-plugins-nrpe"]: ensure => latest, }

  service { "xinetd":
    ensure  => running,
    enable  => true,
    require => Package["xinetd"],
    restart => "/etc/init.d/xinetd reload",
  }

  file { 
    "/etc/xinetd.d/nrpe":
      mode    => "0644",
      owner   => root,
      group   => root,
      notify  => Service["xinetd"],
      content => template("nagios/xinetd-nrpe.erb");
    "/etc/nagios/nrpe.cfg":
      mode    => "0644",
      owner   => root,
      group   => root,
      notify  => Service["xinetd"],
      content => template("nagios/nrpe.cfg"),
      require => Package["nrpe"];
    "/etc/nrpe.d":
      ensure => directory,
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/nrpe-generic.cfg"),
      notify  => Service["xinetd"];
    "/etc/nrpe.d/generic.cfg":
      mode    => "0644",
      owner   => root,
      group   => root,
      content => template("nagios/nrpe-generic.cfg"),
      notify  => Service["xinetd"],
      require => File["/etc/nrpe.d"];
  }

  Nagios_service {
    target => "/etc/nagios/servers/${hostname}.cfg",
  }

  @@nagios_service { 
    "check_load_${fqdn}":
      ensure                => "present",
      host_name             => "$fqdn",
      service_description   => "Load for host: ${fqdn}",
      check_command         => "check_nrpe!check_load!2.0,2.0,0.9 2.0,2.0,1.0",
      max_check_attempts    => 5,
      normal_check_interval => 30,
      retry_check_interval  => 1,
      check_period          => 24x7,
      notification_interval => 120,
      notification_period   => 24x7,
      notification_options  => "w,u,c,r,f",
      contact_groups        => "localadmins";
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
      contact_groups        => "localadmins";
    "check_swap_${fqdn}":
      ensure                => "present",
      host_name             => "$fqdn",
      service_description   => "Swap check for host: ${fqdn}",
      check_command         => "check_nrpe!check_swap!20% 10%",
      max_check_attempts    => 5,
      normal_check_interval => 30,
      retry_check_interval  => 1,
      check_period          => 24x7,
      notification_interval => 120,
      notification_period   => 24x7,
      notification_options  => "w,u,c,r,f",
      contact_groups        => "localadmins";
  }
}
