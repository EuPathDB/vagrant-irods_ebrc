# Install Postgres and configure a iRODS iCAT database
class profiles::irods_postgres_provider {

  $db_name          = hiera('irods::provider::db_name')
  $db_user          = hiera('irods::provider::db_user')
  $db_password      = hiera('irods::provider::db_password')
  $db_repl_user     = hiera('irods::provider::db_repl_user')
  $db_repl_password = hiera('irods::provider::db_repl_password')

  include ::postgresql::server

  Class['postgresql::server'] ->
  Postgresql::Server::Db[$db_name]

  postgresql::server::db { $db_name:
    user     => $db_user,
    password => postgresql_password(
      $db_user,
      $db_password
    ),
  }

  postgresql::server::database_grant { $db_name:
    privilege => 'ALL',
    db        => $db_name,
    role      => $db_user,
  }

  postgresql::server::pg_hba_rule {'irods access to local socket':
    type        => 'local',
    database    => $db_name,
    user        => $db_user,
    auth_method => 'md5',
    order       => '001',
  }

  # replication configs
  postgresql::server::config_entry{'wal_keep_segments': value => '5',}
  postgresql::server::config_entry{'max_wal_senders': value => '5',}
  postgresql::server::config_entry{'wal_level': value => 'hot_standby',}


  # create replication user
  postgresql::server::role { $db_repl_user:
    password_hash => postgresql_password($db_repl_user, $db_repl_password),
    replication   => true,
  }

  # grant access to replication
  postgresql::server::pg_hba_rule { 'allow replication user to access replication':
        type        => 'host',
        database    => 'replication',
        user        => $db_repl_user,
        address     => '0.0.0.0/0', #TODO lock this down more appropriately
        auth_method => 'md5',
  }

  # allow connections to postgres for slave
  firewalld_rich_rule { 'postgres connection for slave':
    ensure => present,
    zone   => 'public',
    port   => {
      'port'     => '5432',
      'protocol' => 'tcp',
    },
    action => 'accept',
  }


}
