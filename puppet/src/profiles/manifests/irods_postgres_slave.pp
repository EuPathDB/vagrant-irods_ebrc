# Install Postgres and configure as a slave of provider iRODS iCAT database
class profiles::irods_postgres_slave {

  $db_repl_password = hiera('irods::provider::db_repl_password')
  $db_repl_user     = hiera('irods::provider::db_repl_user')

  include ::postgresql::server

  # configs needed on slave
  postgresql::server::config_entry{'hot_standby': value => 'on',}

  postgresql::server::recovery {'Create a recovery.conf file with the following defined parameters':
    standby_mode     => 'on',
    primary_conninfo => "host=provider.irods.vm port=5432 user=replicator password=$db_repl_password",
    trigger_file     => '/tmp/postgresql.trigger',
  }


  # create .pgpass file for initial backup
  file { '/var/lib/pgsql/.pgpass':
    ensure  => present,
    content => "provider.irods.vm:5432:replication:$db_repl_user:$db_repl_password\n",
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0600',
  }

  # do initial backup if no data/base
  exec { 'initial replication backup':
    command => "/bin/pg_basebackup -h provider.irods.vm -D /var/lib/pgsql/data/ -U $db_repl_user -v -P --xlog-method=stream",
    user    => 'postgres',
    unless  => '/bin/test -d /var/lib/pgsql/data/base',
  }

}
