#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#include <mosquitto.h>
#include <mosquitto_plugin.h>

#include <jwt.h>

#define DEFAULT_JWT_TOKEN_SECRET "secret"
static char *jwt_token_secret = NULL;

int mosquitto_auth_plugin_version(void)
{
  return MOSQ_AUTH_PLUGIN_VERSION;
}

int mosquitto_auth_plugin_init(void **user_data, struct mosquitto_auth_opt *auth_opts, int auth_opt_count)
{
  // get our config values...
  int i = 0;
  for (i = 0; i < auth_opt_count; i++)
  {
#ifdef MQAP_DEBUG
    fprintf(stderr, "AuthOptions: key=%s, val=%s\n", auth_opts[i].key, auth_opts[i].value);
#endif
    if (strcmp(auth_opts[i].key, "jwt_token_secret") == 0)
    {
      jwt_token_secret = auth_opts[i].value;
    }
  }

  // defaults here...
  if (jwt_token_secret == NULL)
  {
    jwt_token_secret = DEFAULT_JWT_TOKEN_SECRET;
  }

  return MOSQ_ERR_SUCCESS;
}

int mosquitto_auth_plugin_cleanup(void *user_data, struct mosquitto_auth_opt *auth_opts, int auth_opt_count)
{
  return MOSQ_ERR_SUCCESS;
}

int mosquitto_auth_security_init(void *user_data, struct mosquitto_auth_opt *auth_opts, int auth_opt_count, bool reload)
{
  return MOSQ_ERR_SUCCESS;
}

int mosquitto_auth_security_cleanup(void *user_data, struct mosquitto_auth_opt *auth_opts, int auth_opt_count, bool reload)
{
  return MOSQ_ERR_SUCCESS;
}

int mosquitto_auth_unpwd_check(void *user_data, const char *username, const char *password)
{

  jwt_t *jwt;

  if (jwt_decode(&jwt, username, (unsigned char *)jwt_token_secret, strlen(jwt_token_secret)) != 0)
  {
    return MOSQ_ERR_AUTH;
  }

  jwt_free(jwt);

  return MOSQ_ERR_SUCCESS;
}

int mosquitto_auth_acl_check(void *user_data, const char *clientid, const char *username, const char *topic, int access)
{
  if (username == NULL)
  {
    // If the username is NULL then it's an anonymous user, currently we let
    // this pass assuming the admin will disable anonymous users if required.
    return MOSQ_ERR_SUCCESS;
  }

  return (true ? MOSQ_ERR_SUCCESS : MOSQ_ERR_ACL_DENIED);
}

int mosquitto_auth_psk_key_get(void *user_data, const char *hint, const char *identity, char *key, int max_key_len)
{
  return MOSQ_ERR_AUTH;
}