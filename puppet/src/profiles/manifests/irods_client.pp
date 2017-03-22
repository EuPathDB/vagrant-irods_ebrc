class profiles::irods_client {

  include ::profiles::base
  include ::irods::client

  Class['profiles::base'] ->
  Class['irods::client']

}
