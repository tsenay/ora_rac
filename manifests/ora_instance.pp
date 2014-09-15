# == Class: cluster::config
#
#
# === Parameters
#
# === Variables
#
# === Authors
#
# Bert Hajee <hajee@moretIA.com>
#
# === Copyright
#
# Copyright 2014 Bert Hajee
#
define ora_rac::ora_instance(
	$on,
	$number,
	$thread,
){


  tablespace{"${on}/UNDOTBS${number}":
    contents  => 'undo',
    datafile  => '+DATA',
  }

  init_param{"${on}/${name}/instance_number":
    ensure    => present,
    scope     => 'spfile',
    value     => $number,
  }

  init_param{"${on}/${name}/instance_name":
    ensure    => present,
    scope     => 'spfile',
    value     => $name,
  }

  init_param{"${on}/${name}/thread":
    ensure    => present,
    scope     => 'spfile',
    value     => $thread,
  }

  init_param{"${on}/${name}/undo_tablespace":
    ensure  => present,
    scope   => 'spfile',
    value   => "UNDOTBS${number}",
    require => Tablespace["${on}/UNDOTBS${number}"],
  }

  file{"/tmp/add_logfiles_${thread}.sql":
    ensure  => 'present',
    content => template('ora_rac/add_logfiles.sql.erb'),
  }

  oracle_exec{"${on}/@/tmp/add_logfiles_${thread}.sql":
    require   => [
      File["/tmp/add_logfiles_${thread}.sql"],
    ]
  }

  oracle_thread{"${on}/${thread}":
    ensure  => 'enabled',
    require   => [
      Init_param["${on}/${name}/undo_tablespace"],
      Oracle_exec["${on}/@/tmp/add_logfiles_${thread}.sql"],
      ]
  }

}
