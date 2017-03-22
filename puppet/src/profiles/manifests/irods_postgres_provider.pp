# Install Postgres and configure a iRODS iCAT database
class profiles::irods_postgres_provider {

  $db_name     = hiera('irods::provider::db_name')
  $db_user     = hiera('irods::provider::db_user')
  $db_password = hiera('irods::provider::db_password')

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

}
