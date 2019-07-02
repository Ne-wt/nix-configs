{common, pkgs, ...}:
let
  ldapConfig = pkgs.writeText "dovecot-ldap-config" ''
    hosts = ${common.ldapHost}
    ldap_version = 3
    auth_bind = no
    base = ou=accounts,o=redbrick
    deref = never
    scope = subtree
    user_attrs =
    user_filter = (&(objectclass=posixAccount)(uid=%n)
    pass_attrs = uid=user,userPassword=password
    pass_filter = (&(objectclass=posixAccount)(uid=%n))
    default_pass_scheme = CRYPT
  '';

in pkgs.writeText "dovecot-auth-config" ''
  # cache all authentication results for one hour
  auth_cache_size = 10M
  auth_cache_ttl = 1 hour
  auth_cache_negative_ttl = 1 hour

  # only use plain username/password auth - OK since everything is over TLS
  auth_mechanisms = plain

  # passdb specifies how users are authenticated - LDAP in my case
  passdb {
    driver = ldap
    args = ${ldapConfig}
  }
''
