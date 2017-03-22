# iRODS consumer server
class profiles::irods_consumer {

  include ::profiles::base
  include ::profiles::irods_consumer_base
  include ::irods::consumer

  Class['profiles::base'] ->
  Class['profiles::irods_consumer_base'] ->
  Class['irods::consumer']

  package { 'irods-resource-plugin-shareuf-4.2.0':
    ensure  => 'latest',
    require => Class['::irods::consumer'],
  }

}
