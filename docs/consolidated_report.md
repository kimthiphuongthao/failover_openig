## [](https://doc.openidentityplatform.org/openig/gateway-guide/chap-install#load-balancing)Preparing For Load Balancing and Failover
For a high scale or highly available deployment, you can prepare a pool of OpenIG servers with nearly identical configurations, and then load balance requests across the pool, routing around any servers that become unavailable. Load balancing allows the service to handle more load.
Before you spread requests across multiple servers, however, you must determine what to do with state information that OpenIG saves in the context, or retrieves locally from the OpenIG server system. If information is retrieved locally, then consider setting up failover. If one server becomes unavailable, another server in the pool can take its place. The benefit of failover is that a server failure can be invisible to client applications. OpenIG can save state information in several ways:
  * Handlers including a `SamlFederationHandler` or a custom `ScriptableHandler` can store information in the context. Most handlers depend on information in the context, some of which is first stored by OpenIG.
  * Some filters, such as `AssignmentFilters`, `HeaderFilters`, `OAuth2ClientFilters`, `OAuth2ResourceServerFilters`, `ScriptableFilters`, `SqlAttributesFilters`, and `StaticRequestFilters`, can store information in the context. Most filters depend on information in the request, response, or context, some of which is first stored by OpenIG.


OpenIG can also retrieve information locally in several ways:
  * Some filters and handlers, such as `FileAttributesFilters`, `ScriptableFilters`, `ScriptableHandlers`, and `SqlAttributesFilters`, can depend on local system files or container configuration.


By default the context data resides in memory in the container where OpenIG runs. This includes the default session implementation, which is backed by the HttpSession that the container handles. You can opt to store session data on the user-agent instead, however. For details and to consider whether your data fits, see [JwtSession(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#JwtSession) in the _Configuration Reference_. When you use the `JwtSession` implementation, be sure to share the encryption keys across all servers, so that any server can read session cookies from any other.
If your data does not fit in an HTTP cookie, for example, because when encrypted it is larger than 4 KB, consider storing a reference in the cookie, and then retrieve the data by using another filter. OpenIG logs warning messages if the `JwtSession` cookie is too large. Using a reference can also work when a server becomes unavailable, and the load balancer must fail requests over to another server in the pool.
If some data attached to a context must be stored on the server side, then you have additional configuration steps to perform for session stickiness and for session replication. Session stickiness means that the load balancer sends all requests from the same client session to the same server. Session stickiness helps to ensure that a client request goes to the server holding the original session data. Session replication involves writing session data either to other servers or to a data store, so that if one server goes down, other servers can read the session data and continue processing. Session replication helps when one server fails, allowing another server to take its place without having to start the session over again. If you set up session stickiness but not session replication, when a server crashes, the client session information for that server is lost, and the client must start again with a new session.
How you configure session stickiness and session replication depends on your load balancer and on your container. Tomcat can help with session stickiness, and a Tomcat cluster can handle session replication:
  * If you choose to use the [Tomcat connector](https://tomcat.apache.org/connectors-doc/) (mod_jk) on your web server to perform load balancing, then see the [LoadBalancer HowTo](http://tomcat.apache.org/connectors-doc/common_howto/loadbalancers.html) for details.
In the HowTo, you configure the `jvmRoute` attribute in the Tomcat server configuration, `/path/to/tomcat/conf/server.xml`, to identify the server. The connector can use this identifier to achieve session stickiness.
  * A Tomcat [cluster](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html) configuration can handle session replication. When setting up a cluster configuration, the [ClusterManager](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html) defines the session replication implementation.


Jetty has provisions for session stickiness, and also for session replication through clustering:
  * Jetty’s persistent session mechanism appends a node ID to the session ID in the same way Tomcat appends the `jvmRoute` value to the session cookie. This can be useful for session stickiness if your load balancer examines the session ID.
  * [Session Clustering with a Database](http://www.eclipse.org/jetty/documeation/current/session-clustering-jdbc.html) describes how to configure Jetty to persist sessions over JDBC, allowing session replication.
Unless it is set up to be highly available, the database can be a single point of failure in this case.
  * [Session Clustering with MongoDB](http://www.eclipse.org/jetty/documentation/current/session-clustering-mongodb.html) describes how to configure Jetty to persist sessions in MongoDB, allowing session replication.
The Jetty documentation recommends this implementation when session data is seldom written but often read.


## Content from: https://doc.openidentityplatform.org/openig/reference/misc-conf#JwtSession

We would like to use third party cookies and scripts to improve the functionality of this website. Approve [More info](https://www.openidentityplatform.org/privacy)
[Open Identity Platform](https://doc.openidentityplatform.org/) // [OpenIG: Identity Gateway](https://doc.openidentityplatform.org/openig/reference/misc-conf)
![](https://www.google.com/images/cleardot.gif)[![](https://www.google.com/images/cleardot.gif)​![](https://www.google.com/images/cleardot.gif)▼](https://doc.openidentityplatform.org/openig/reference/misc-conf)
Projects 
[OpenDJ: Directory Services](https://doc.openidentityplatform.org/opendj/) [OpenAM: Access Management](https://doc.openidentityplatform.org/openam/) [OpenIG: Identity Gateway](https://doc.openidentityplatform.org/openig/) [OpenIDM: Identity Management](https://doc.openidentityplatform.org/openidm/)
[ ](https://github.com/OpenIdentityPlatform)
### [OpenIG: Identity Gateway](https://doc.openidentityplatform.org/openig/)
  *     * [Gateway Guide](https://doc.openidentityplatform.org/openig/gateway-guide/)
      * [Preface](https://doc.openidentityplatform.org/openig/gateway-guide/preface)
      * [Understanding OpenIG](https://doc.openidentityplatform.org/openig/gateway-guide/chap-start-here)
      * [Getting Started](https://doc.openidentityplatform.org/openig/gateway-guide/chap-quickstart)
      * [Installation in Detail](https://doc.openidentityplatform.org/openig/gateway-guide/chap-install)
      * [Getting Login Credentials From Data Sources](https://doc.openidentityplatform.org/openig/gateway-guide/chap-credentials-tutorial)
      * [Getting Login Credentials From OpenAM](https://doc.openidentityplatform.org/openig/gateway-guide/chap-password-capture-replay-tutorial)
      * [OpenIG As an OpenAM Policy Enforcement Point](https://doc.openidentityplatform.org/openig/gateway-guide/chap-pep)
      * [OpenIG As a SAML 2.0 Service Provider](https://doc.openidentityplatform.org/openig/gateway-guide/chap-federation)
      * [OpenIG As an OAuth 2.0 Resource Server](https://doc.openidentityplatform.org/openig/gateway-guide/chap-oauth2-rs)
      * [OpenIG As an OAuth 2.0 Client or OpenID Connect Relying Party](https://doc.openidentityplatform.org/openig/gateway-guide/chap-oauth2-client)
      * [Transforming OpenID Connect ID Tokens Into SAML Assertions](https://doc.openidentityplatform.org/openig/gateway-guide/chap-ttf)
      * [OpenIG As an UMA Resource Server](https://doc.openidentityplatform.org/openig/gateway-guide/chap-uma)
      * [Configuring Routes](https://doc.openidentityplatform.org/openig/gateway-guide/chap-routing)
      * [Configuration Templates](https://doc.openidentityplatform.org/openig/gateway-guide/chap-gateway-templates)
      * [Extending OpenIG’s Functionality](https://doc.openidentityplatform.org/openig/gateway-guide/chap-extending)
      * [Auditing and Monitoring OpenIG](https://doc.openidentityplatform.org/openig/gateway-guide/chap-auditing)
      * [Throttling the Rate of Requests to a Protected Application](https://doc.openidentityplatform.org/openig/gateway-guide/chap-throttling)
      * [Logging Events in OpenIG](https://doc.openidentityplatform.org/openig/gateway-guide/chap-logging)
      * [Troubleshooting](https://doc.openidentityplatform.org/openig/gateway-guide/chap-troubleshooting)
      * [SAML 2.0 and Multiple Applications](https://doc.openidentityplatform.org/openig/gateway-guide/appendix-multiple-sps)
  *     * [Configuration Reference](https://doc.openidentityplatform.org/openig/reference/)
      * [Preface](https://doc.openidentityplatform.org/openig/reference/preface)
      * [Required Configuration](https://doc.openidentityplatform.org/openig/reference/required-conf)
      * [Handlers](https://doc.openidentityplatform.org/openig/reference/handlers-conf)
      * [Filters](https://doc.openidentityplatform.org/openig/reference/filters-conf)
      * [Decorators](https://doc.openidentityplatform.org/openig/reference/decorators-conf)
      * [Logging Framework](https://doc.openidentityplatform.org/openig/reference/logging-conf)
      * [Audit Framework](https://doc.openidentityplatform.org/openig/reference/audit-conf)
      * [Throttling Filters and Policies](https://doc.openidentityplatform.org/openig/reference/throttling-conf)
      * [Miscellaneous Heap Objects](https://doc.openidentityplatform.org/openig/reference/misc-conf)
      * [Expressions](https://doc.openidentityplatform.org/openig/reference/expressions-conf)
      * [Requests, Responses, and Contexts](https://doc.openidentityplatform.org/openig/reference/object-model-conf)
      * [Release Levels and Interface Stability](https://doc.openidentityplatform.org/openig/reference/appendix-interface-stability)


OpenIG: Identity Gateway
  * [OpenAM: Access Management](https://doc.openidentityplatform.org/openam/)
  * [OpenDJ: Directory Services](https://doc.openidentityplatform.org/opendj/)
  * [OpenIDM: Identity Management](https://doc.openidentityplatform.org/openidm/)
  * [OpenIG: Identity Gateway](https://doc.openidentityplatform.org/openig/)


[](https://doc.openidentityplatform.org/)
  * [OpenIG: Identity Gateway](https://doc.openidentityplatform.org/openig/)
  * [Configuration Reference](https://doc.openidentityplatform.org/openig/reference/)
  * [Miscellaneous Heap Objects](https://doc.openidentityplatform.org/openig/reference/misc-conf)


[Edit this Page](https://github.com/OpenIdentityPlatform/OpenIG/edit/master/openig-doc/src/main/asciidoc/reference/misc-conf.adoc)
|
[Download PDF](https://raw.githubusercontent.com/wiki/OpenIdentityPlatform/OpenIG/asciidoc/pdf/Configuration_Reference.pdf)
### Contents
  * [ClientRegistration — Hold OAuth 2.0 client registration information](https://doc.openidentityplatform.org/openig/reference/misc-conf#ClientRegistration)
  * [JwtSession — store sessions in encrypted JWT cookies](https://doc.openidentityplatform.org/openig/reference/misc-conf#JwtSession)
  * [KeyManager — configure a Java Secure Socket Extension KeyManager](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyManager)
  * [KeyStore — configure a Java KeyStore](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore)
  * [Issuer — Describe an Authorization Server or OpenID Provider](https://doc.openidentityplatform.org/openig/reference/misc-conf#Issuer)
  * [ScheduledExecutorService — schedule the execution of tasks](https://doc.openidentityplatform.org/openig/reference/misc-conf#ScheduledExecutorService)
  * [TemporaryStorage — cache streamed content](https://doc.openidentityplatform.org/openig/reference/misc-conf#TemporaryStorage)
  * [TrustManager — configure a Java Secure Socket Extension TrustManager](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager)
  * [TrustAllManager — a TrustManager that blindly trusts all servers](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustAllManager)
  * [UmaService — represent an UMA resource server configuration](https://doc.openidentityplatform.org/openig/reference/misc-conf#UmaService)


# Miscellaneous Heap Objects
### Contents
  * [ClientRegistration — Hold OAuth 2.0 client registration information](https://doc.openidentityplatform.org/openig/reference/misc-conf#ClientRegistration)
  * [JwtSession — store sessions in encrypted JWT cookies](https://doc.openidentityplatform.org/openig/reference/misc-conf#JwtSession)
  * [KeyManager — configure a Java Secure Socket Extension KeyManager](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyManager)
  * [KeyStore — configure a Java KeyStore](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore)
  * [Issuer — Describe an Authorization Server or OpenID Provider](https://doc.openidentityplatform.org/openig/reference/misc-conf#Issuer)
  * [ScheduledExecutorService — schedule the execution of tasks](https://doc.openidentityplatform.org/openig/reference/misc-conf#ScheduledExecutorService)
  * [TemporaryStorage — cache streamed content](https://doc.openidentityplatform.org/openig/reference/misc-conf#TemporaryStorage)
  * [TrustManager — configure a Java Secure Socket Extension TrustManager](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager)
  * [TrustAllManager — a TrustManager that blindly trusts all servers](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustAllManager)
  * [UmaService — represent an UMA resource server configuration](https://doc.openidentityplatform.org/openig/reference/misc-conf#UmaService)


## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#ClientRegistration)ClientRegistration — Hold OAuth 2.0 client registration information
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e13939)Description
A ClientRegistration holds information about registration with an OAuth 2.0 authorization server or OpenID Provider.
The configuration includes the client credentials that are used to authenticate to the identity provider. The client credentials can be included directly in the configuration, or retrieved in some other way using an expression, described in [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions).
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e13953)Usage
```
{
 "name": string,
 "type": "ClientRegistration",
 "config": {
  "clientId": expression,
  "clientSecret": expression,
  "issuer": Issuer reference,
  "registrationHandler": Handler reference,
  "scopes": [ expression, ...],
  "tokenEndpointUseBasicAuth": boolean
 }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e13959)Properties
The client registration configuration object properties are as follows: 

`"name"`: _string, required_
    
A name for the client registration. 

`"clientId"`: _expression, required_
    
The `client_id` obtained when registering with the authorization server.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"clientSecret"`: _expression, required_
    
The `client_secret` obtained when registering with the authorization server.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"issuer"`: _Issuer reference, required_
    
The provider configuration to use for this client registration.
Provide either the name of a Issuer object defined in the heap, or an inline Issuer configuration object.
See also [Issuer(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#Issuer). 

`"registrationHandler"`: _Handler reference, optional_
    
Invoke this HTTP client handler to communicate with the authorization server.
Provide either the name of a Handler object defined in the heap, or an inline Handler configuration object.
Usually set this to the name of a ClientHandler configured in the heap, or a chain that ends in a ClientHandler.
Default: OpenIG uses the default ClientHandler.
See also [Handlers](https://doc.openidentityplatform.org/openig/reference/handlers-conf#handlers-conf), [ClientHandler(5)](https://doc.openidentityplatform.org/openig/reference/handlers-conf#ClientHandler). 

`"scopes"`: _array of expressions, optional_
    
OAuth 2.0 scopes to use with this client registration.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"tokenEndpointUseBasicAuth"`: _boolean, optional_
    
Whether to perform client authentication to the provider using HTTP Basic authentication when sending a request to the provider’s OAuth 2.0 token endpoint.
When set to `true`, the client credentials are sent using HTTP Basic authentication as in the following example request:
```
POST /oauth2/token HTTP/1.1
Host: as.example.com
Authorization: Basic ....
Content-Type: application/x-www-form-urlencoded
grant_type=authorization_code&code=...
```

httprequest![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
When set to `false`, the client credentials are sent in HTTP POST form data as in the following example request:
```
POST /oauth2/token HTTP/1.1
Host: as.example.com
Content-Type: application/x-www-form-urlencoded
grant_type=authorization_code&client_id=.....&client_secret=.....&code=...
```

httprequest![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
Some providers accept both authentication methods. For providers that strictly enforce how the client must authenticate, such as recent versions of OpenAM, you must align the configuration with that of the provider.
If the provider does not support the configured authentication method, then according to RFC 6749 [The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749#section-5.2) the provider sends an HTTP 400 Bad Request response with an `invalid_client` error message as in the following example response:
```
HTTP/1.1 400 Bad Request
Content-Type: application/json;charset=UTF-8
Cache-Control: no-store
Pragma: no-cache
{
 "error":"invalid_client"
}
```

httprequest![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
Default: `true`
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14107)Example
The following example shows a client registration for OpenAM. In this example client credentials are replaced with . In the actual configuration either include the credentials and protect the configuration file or obtain the credentials from the environment in a safe manner:
```
{
  "name": "OpenIDConnectRelyingParty",
  "type": "ClientRegistration",
  "config": {
    "clientId": "**********",
    "clientSecret": "**********",
    "issuer": "openam",
    "redirect_uris": [
      "https://openig.example.com:8443/openid/callback"
    ],
    "scopes": [
      "openid",
      "profile"
    ]
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14118)Javadoc
[org.forgerock.openig.filter.oauth2.client.ClientRegistration](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/filter/oauth2/client/ClientRegistration.html)
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14125)See Also
[Issuer(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#Issuer), [OAuth2ClientFilter(5)](https://doc.openidentityplatform.org/openig/reference/filters-conf#OAuth2ClientFilter)
[The OAuth 2.0 Authorization Framework](http://tools.ietf.org/html/rfc6749)
[OAuth 2.0 Bearer Token Usage](http://tools.ietf.org/html/rfc6750)
[OpenID Connect](http://openid.net/connect/)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#JwtSession)JwtSession — store sessions in encrypted JWT cookies
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14161)Description
A JwtSession object holds settings for storing session information in encrypted JSON Web Token (JWT) cookies.
In this context, _encrypted JWT cookie_ means an HTTP cookie whose value is an encrypted JWT. The payload of the encrypted JWT is a JSON representation of the session information.
The JWT cookie lifetime is Session (not persistent), meaning the user-agent deletes the JWT cookie when it shuts down.
When using this storage implementation, you must use data types for session information that can be mapped to [JavaScript Object Notation](http://json.org) (JSON). JSON allows strings, numbers, `true`, `false`, `null`, as well as arrays and JSON objects composed of the same primitives. Java and Groovy types that can be mapped include Java primitive types and `null`, String and CharSequence objects, as well as List and Map objects.
As browser cookie storage capacity is limited to 4 KB, and encryption adds overhead, take care to limit the size of any JSON that you store. Rather than store larger data in the session information, consider storing a reference instead.
When a request enters a route that uses a new session type, the scope of the session information becomes limited to the route. OpenIG builds a new session object and does not propagate any existing session information to the new object. `session` references the new session object. When the response then exits the route, the session object is closed, and serialized to a JWT cookie in this case, and `session` references the previous session object. Session information set inside the route is no longer available.
An HTTP client that performs multiple requests in a session that modify the content of its session can encounter inconsistencies in the session information. This is because OpenIG does not share JwtSessions across threads. Instead, each thread has its own JwtSession objects that it modifies as necessary, writing its own session to the JWT cookie regardless of what other threads do.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14207)Usage
```
{
  "name": string,
  "type": "JwtSession",
  "config": {
    "keystore": KeyStore reference,
    "alias": string,
    "password": configuration expression,
    "cookieName": string,
    "sessionTimeout": duration,
    "sharedSecret": string
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
An alternative value for type is JwtSessionFactory.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14215)Properties 

`"keystore"`: _KeyStore reference, optional_
    
The keystore holding the key pair with the private key used to decrypt the JWT.
Provide either the name of the KeyStore object defined in the heap, or the inline KeyStore configuration object inline.
Default: When no keystore is specified, OpenIG generates a unique key pair, and stores the key pair in memory. With JWTs encrypted using a unique key pair generated at runtime, OpenIG cannot decrypt the JWTs after a restart, nor can it decrypt such JWTs encrypted by another OpenIG server.
See also [KeyStore(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore). 

`"alias"`: _string, required when keystore is used_
    
Alias for the private key. 

`"password"`: _configuration expression, required when keystore is used_
    
The password to read the private key from the keystore.
A configuration expression, described in [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions) is independent of the request, response, and contexts, so do not use expressions that reference their properties. You can, however, use `${env['variable']}`, `${system['property']}`, and all the built-in functions listed in [Functions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Functions). 

`"cookieName"` _string, optional_
    
The name of the JWT cookie stored on the user-agent.
Default: `openig-jwt-session` 

`"sessionTimeout"` _duration, optional_
    
The amount of time before the cookie session expires.
A [duration](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/util/Duration.html) is a lapse of time expressed in English, such as `23 hours 59 minutes and 59 seconds`.
Durations are not case sensitive.
Negative durations are not supported.
The following units can be used in durations:
  * `indefinite`, `infinity`, `undefined`, `unlimited`: unlimited duration
  * `zero`, `disabled`: zero-length duration
  * `days`, `day`, `d`: days
  * `hours`, `hour`, `h`: hours
  * `minutes`, `minute`, `min`, `m`: minutes
  * `seconds`, `second`, `sec`, `s`: seconds
  * `milliseconds`, `millisecond`, `millisec`, `millis`, `milli`, `ms`: milliseconds
  * `microseconds`, `microsecond`, `microsec`, `micros`, `micro`, `us`: microseconds
  * `nanoseconds`, `nanosecond`, `nanosec`, `nanos`, `nano`, `ns`: nanoseconds
Default: 30 minutes


A zero duration for session timeout is not a valid setting. The maximum session timeout duration is 3650 days (approximately 10 years). If you set a longer duration, OpenIG truncates the duration to the maximum value. 

`"sharedSecret"` _string, optional_
    
Specifies the key used to sign and verify the JWTs.
This attribute is expected to be base-64 encoded. The minimum key size after base-64 decoding is 32 bytes/256 bits (HMAC-SHA-256 is used to sign JWTs). If the provided key is too short, an error message is created.
If this attribute is not specified, random data is generated as the key, and the OpenIG instance can verify only the sessions it has created.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14476)Example
The following example defines a JwtSession for storing session information in a JWT token cookie named `OpenIG`. The JWT is encrypted with a private key that is recovered using the alias `private-key`, and stored in the keystore. The password is both the password for the keystore and also the private key:
```
{
  "name": "JwtSession",
  "type": "JwtSession",
  "config": {
    "keystore": {
      "type": "KeyStore",
      "config": {
        "url": "file://${env['HOME']}/keystore.jks",
        "password": "${system['keypass']}"
      }
    },
    "alias": "private-key",
    "password": "${system['keypass']}",
    "cookieName": "OpenIG"
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14490)Javadoc
[org.forgerock.openig.jwt.JwtSessionManager](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/jwt/JwtSessionManager.html)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyManager)KeyManager — configure a Java Secure Socket Extension KeyManager
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14510)Description
This represents the configuration for a Java Secure Socket Extension [KeyManager](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/javax/net/ssl/KeyManager.html), which manages the keys used to authenticate an SSLSocket to a peer. The configuration references the keystore that actually holds the keys.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14523)Usage
```
{
  "name": string,
  "type": "KeyManager",
  "config": {
    "keystore": KeyStore reference,
    "password": expression,
    "alg": string
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14529)Properties 

`"keystore"`: _KeyStore reference, optional_
    
The keystore that references the store for the actual keys.
Provide either the name of the KeyStore object defined in the heap, or the inline KeyStore configuration object inline.
See also [KeyStore(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore). 

`"password"`: _expression, required_
    
The password to read private keys from the keystore. 

`"alg"` _string, optional_
    
The certificate algorithm to use.
Default: the default for the platform, such as `SunX509`.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions).
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14578)Example
The following example configures a key manager that depends on a KeyStore configuration. The keystore takes a password supplied as a Java system property when starting the container where OpenIG runs, as in `-Dkeypass=password`. This configuration uses the default certificate algorithm:
```
{
  "name": "MyKeyManager",
  "type": "KeyManager",
  "config": {
    "keystore": {
      "type": "KeyStore",
      "config": {
        "url": "file://${env['HOME']}/keystore.jks",
        "password": "${system['keypass']}"
      }
    },
    "password": "${system['keypass']}"
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14591)Javadoc
[org.forgerock.openig.security.KeyManagerHeaplet](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/security/KeyManagerHeaplet.html)
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14599)See Also
[JSSE Reference Guide](https://docs.oracle.com/en/java/javase/11/security/java-secure-socket-extension-jsse-reference-guide.html), [KeyStore(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore), [TrustManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore)KeyStore — configure a Java KeyStore
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14624)Description
This represents the configuration for a Java [KeyStore](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/security/KeyStore.html), which stores cryptographic private keys and public key certificates.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14637)Usage
```
{
  "name": name,
  "type": "KeyStore",
  "config": {
    "url": expression,
    "password": expression,
    "type": string
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14643)Properties 

`"url"`: _expression, required_
    
URL to the keystore file.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"password"`: _expression, optional_
    
The password to read private keys from the keystore.
If the keystore is used as a truststore to store only public key certificates of peers and no password is required to do so, then you do not have to specify this field.
Default: No password is set.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"type"`: _string, optional_
    
The keystore format.
Default: the default for the platform, such as `JKS`.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14694)Example
The following example configures a keystore that references a Java Keystore file, `$HOME/keystore.jks`. The keystore takes a password supplied as a Java system property when starting the container where OpenIG runs, as in `-Dkeypass=password`. As the keystore file uses the default format, no type is specified:
```
{
  "name": "MyKeyStore",
  "type": "KeyStore",
  "config": {
    "url": "file://${env['HOME']}/keystore.jks",
    "password": "${system['keypass']}"
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14710)Javadoc
[org.forgerock.openig.security.KeyStoreHeaplet](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/security/KeyStoreHeaplet.html)
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14718)See Also
[JSSE Reference Guide](https://docs.oracle.com/en/java/javase/11/security/java-secure-socket-extension-jsse-reference-guide.html), [KeyManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyManager), [TrustManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#Issuer)Issuer — Describe an Authorization Server or OpenID Provider
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14743)Description
An Issuer describes an OAuth 2.0 Authorization Server or an OpenID Provider that OpenIG can use as a OAuth 2.0 client or OpenID Connect relying party.
An Issuer is generally referenced from a ClientRegistration, described in [ClientRegistration(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#ClientRegistration).
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14757)Usage
```
{
 "name": string,
 "type": "Issuer",
 "config": {
  "wellKnownEndpoint": URL string,
  "authorizeEndpoint": URI expression,
  "registrationEndpoint": URI expression,
  "tokenEndpoint": URI expression,
  "userInfoEndpoint": URI expression,
  "issuerHandler": Handler reference,
  "supportedDomains": [ domain pattern, ... ]
 }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14763)Properties
If the provider has a well-known configuration URL as defined for OpenID Connect 1.0 Discovery that returns JSON with at least authorization and token endpoint URLs, then you can specify that URL in the provider configuration. Otherwise, you must specify at least the provider authorization and token endpoint URLs, and optionally the registration endpoint and user info endpoint URLs.
The provider configuration object properties are as follows: 

`"name"`: _string, required_
    
A name for the provider configuration. 

`"wellKnownEndpoint"`: _URL string, required unless authorizeEndpoint and tokenEndpoint are specified_
    
The URL to the well-known configuration resource as described in OpenID Connect 1.0 Discovery. 

`"authorizeEndpoint"`: _expression, required unless obtained through wellKnownEndpoint_
    
The URL to the provider’s OAuth 2.0 authorization endpoint.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"registrationEndpoint"`: _expression, optional_
    
The URL to the provider’s OpenID Connect dynamic registration endpoint.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"tokenEndpoint"`: _expression, required unless obtained through wellKnownEndpoint_
    
The URL to the provider’s OAuth 2.0 token endpoint.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"userInfoEndpoint"`: _expression, optional_
    
The URL to the provider’s OpenID Connect UserInfo endpoint.
Default: no UserInfo is obtained from the provider.
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions). 

`"issuerHandler"`: _Handler reference, optional_
    
Invoke this HTTP client handler to communicate with the authorization server.
Provide either the name of a Handler object defined in the heap, or an inline Handler configuration object.
Usually set this to the name of a ClientHandler configured in the heap, or a chain that ends in a ClientHandler.
Default: OpenIG uses the default ClientHandler.
See also [Handlers](https://doc.openidentityplatform.org/openig/reference/handlers-conf#handlers-conf), [ClientHandler(5)](https://doc.openidentityplatform.org/openig/reference/handlers-conf#ClientHandler). 

`"supportedDomains"`: _array of patterns, optional_
    
List of patterns matching domain names handled by this issuer, used as a shortcut for [OpenID Connect discovery](http://openid.net/specs/openid-connect-discovery-1_0.html) before performing [OpenID Connect dynamic registration](http://openid.net/specs/openid-connect-registration-1_0.html).
In summary when the OpenID Provider is not known in advance, it might be possible to discover the OpenID Provider Issuer based on information provided by the user, such as an email address. The OpenID Connect discovery specification explains how to use [WebFinger](https://tools.ietf.org/html/rfc7033) to discover the issuer. OpenIG can discover the issuer in this way. As a shortcut OpenIG can also use supported domains lists to find issuers already described in the OpenIG configuration.
To use this shortcut, OpenIG extracts the domain from the user input, and looks for an issuer whose supported domains list contains a match.
Supported domains patterns match host names with optional port numbers. Do not specify a URI scheme such as HTTP. OpenIG adds the scheme. For instance, `*.example.com` matches any host in the `example.com` domain. You can specify the port number as well as in `host.example.com:8443`. Patterns must be valid regular expression patterns according to the rules for the Java [Pattern](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/regex/Pattern.html) class.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14908)Examples
The following example shows an OpenAM issuer configuration for OpenAM. OpenAM exposes a well-known endpoint for the provider configuration, but this example demonstrates use of the other fields:
```
{
  "name": "openam",
  "type": "Issuer",
  "config": {
    "authorizeEndpoint":
     "https://openam.example.com:8443/openam/oauth2/authorize",
    "registration_endpoint":
     "https://openam.example.com:8443/openam/oauth2/connect/register",
    "tokenEndpoint":
     "https://openam.example.com:8443/openam/oauth2/access_token",
    "userInfoEndpoint":
     "https://openam.example.com:8443/openam/oauth2/userinfo",
    "supportedDomains": [ "mail.example.*", "docs.example.com:8443" ]
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
The following example shows an issuer configuration for Google:
```
{
  "name": "google",
  "type": "Issuer",
  "config": {
    "wellKnownEndpoint":
     "https://accounts.google.com/.well-known/openid-configuration",
    "supportedDomains": [ "gmail.*", "googlemail.com:8052" ]
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14921)Javadoc
[org.forgerock.openig.filter.oauth2.client.Issuer](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/filter/oauth2/client/Issuer.html)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#ScheduledExecutorService)ScheduledExecutorService — schedule the execution of tasks
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14940)Description
An executor service to schedule tasks for execution after a delay or for repeated execution with a fixed interval of time in between each execution. You can configure the number of threads in the executor service and how the executor service is stopped.
The `ScheduledExecutorService` is shared by all downstream components that use an executor service.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14955)Usage
```
{
  "name": string,
  "type": "ScheduledExecutorService",
  "config": {
    "corePoolSize”: integer or expression<integer>,
    "gracefulStop": boolean or expression<boolean>,
    "gracePeriod" : duration string or expression<duration string>
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e14961)Properties 

`"corePoolSize"`: _integer or expression <integer>, optional_
    
The minimum number of threads to keep in the pool. If this property is an expression, the expression is evaluated as soon as the configuration is read.
The value must be an integer greater than zero.
Default: 1 

`"gracefulStop"`: _boolean or expression <boolean> , optional_
    
Defines how the executor service stops. If this property is an expression, the expression is evaluated as soon as the configuration is read.
If true, the executor service does the following:
  * Blocks the submission of new jobs.
  * Allows running jobs to continue.
  * If a grace period is defined, waits for up to that maximum time for running jobs to finish before it stops.
If false, the executor service does the following:
  * Blocks the submission of new jobs.
  * Removes submitted jobs without running them.
  * Attempts to end running jobs.
  * If a grace period is defined, ignores it.


Default: true 

`"gracePeriod"`: _duration string or expression <duration string>, optional_
    
The maximum time that the executor service waits for running jobs to finish before it stops. If this property is an expression, the expression is evaluated as soon as the configuration is read.
If all jobs finish before the grace period, the executor service stops without waiting any longer. If jobs are still running after the grace period, the executor service stops anyway and prints a message.
When `gracefulStop` is `false`, the grace period is ignored.
A [duration](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/util/Duration.html) is a lapse of time expressed in English, such as `23 hours 59 minutes and 59 seconds`.
Durations are not case sensitive.
Negative durations are not supported.
The following units can be used in durations:
  * `indefinite`, `infinity`, `undefined`, `unlimited`: unlimited duration
  * `zero`, `disabled`: zero-length duration
  * `days`, `day`, `d`: days
  * `hours`, `hour`, `h`: hours
  * `minutes`, `minute`, `min`, `m`: minutes
  * `seconds`, `second`, `sec`, `s`: seconds
  * `milliseconds`, `millisecond`, `millisec`, `millis`, `milli`, `ms`: milliseconds
  * `microseconds`, `microsecond`, `microsec`, `micros`, `micro`, `us`: microseconds
  * `nanoseconds`, `nanosecond`, `nanosec`, `nanos`, `nano`, `ns`: nanoseconds


Default: 10 seconds
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15197)Example
The following example creates a thread pool to execute tasks. When the executor service is instructed to stop, it blocks the submission of new jobs, and waits for up to 10 seconds for submitted and running jobs to complete before it stops. If any jobs are still submitted or running after 10 seconds, the executor service stops anyway and prints a message.
```
{
  "name": "ExecutorService",
  "comment": "Default service for executing tasks in the background.",
  "type": "ScheduledExecutorService",
  "config": {
    "corePoolSize": 5,
    "gracefulStop": true,
    "gracePeriod": "10 seconds"
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15205)Javadoc
[org.forgerock.openig.thread.ScheduledExecutorServiceHeaplet](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/thread/ScheduledExecutorServiceHeaplet.html)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#TemporaryStorage)TemporaryStorage — cache streamed content
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15225)Description
Allocates temporary buffers for caching streamed content during request processing. Initially uses memory; when the memory limit is exceeded, switches to a temporary file.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15235)Usage
```
{
   "name": string,
   "type": "TemporaryStorage",
   "config": {
     "initialLength": number,
     "memoryLimit": number,
     "fileLimit": number,
     "directory": string
   }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15241)Properties 

`"initialLength"`: _number, optional_
    
The initial length of memory buffer byte array. Default: 8192 (8 KiB). 

`"memoryLimit"`: _number, optional_
    
The length limit of the memory buffer. Exceeding this limit results in promotion from memory to file. Default: 65536 (64 KiB). 

`"fileLimit"`: _number, optional_
    
The length limit of the file buffer. Exceeding this limit results in a thrown exception. Default: 1048576 (1 MiB). 

`"directory"`: _string, optional_
    
The directory where temporary files are created. If omitted, then the system-dependent default temporary directory is used (typically `"/tmp"` on Unix systems). Default: use system-dependent default.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15288)Javadoc
[org.forgerock.openig.io.TemporaryStorage](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/io/TemporaryStorage.html)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager)TrustManager — configure a Java Secure Socket Extension TrustManager
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15306)Description
This represents the configuration for a Java Secure Socket Extension [TrustManager](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/javax/net/ssl/TrustManager.html), which manages the trust material (typically X.509 public key certificates) used to decide whether to accept the credentials presented by a peer. The configuration references the keystore that actually holds the trust material.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15319)Usage
```
{
  "name": string,
  "type": "TrustManager",
  "config": {
    "keystore": KeyStore reference,
    "alg": string
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15325)Properties 

`"keystore"`: _KeyStore reference, optional_
    
The KeyStore that references the store for public key certificates.
Provide either the name of the KeyStore object defined in the heap, or the inline KeyStore configuration object inline.
See also [KeyStore(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore). 

`"alg"` _string, optional_
    
The certificate algorithm to use.
Default: the default for the platform, such as `SunX509`.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15360)Example
The following example configures a trust manager that depends on a KeyStore configuration. This configuration uses the default certificate algorithm:
```
{
  "name": "MyTrustManager",
  "type": "TrustManager",
  "config": {
    "keystore": {
      "type": "KeyStore",
      "config": {
        "url": "file://${env['HOME']}/keystore.jks",
        "password": "${system['keypass']}"
      }
    }
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15368)Javadoc
[org.forgerock.openig.security.TrustManagerHeaplet](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/security/TrustManagerHeaplet.html)
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15376)See Also
[JSSE Reference Guide](https://docs.oracle.com/en/java/javase/11/security/java-secure-socket-extension-jsse-reference-guide.html), [KeyManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyManager), [KeyStore(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#KeyStore)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustAllManager)TrustAllManager — a TrustManager that blindly trusts all servers
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15401)Description
The TrustAllManager blindly trusts all server certificates presented the servers for protected applications. It can be used instead of a [TrustManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager) in test environments to trust server certificates that were not signed by a well-known CA, such as self-signed certificates.
The TrustAllManager is not safe for production use. Use a properly configured [TrustManager(5)](https://doc.openidentityplatform.org/openig/reference/misc-conf#TrustManager) instead.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15417)Usage
```
{
  "name": string,
  "type": "TrustAllManager"
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15423)Example
The following example configures a client handler that blindly trusts server certificates when OpenIG connects to servers over HTTPS:
```
{
  "name": "BlindTrustClientHandler",
  "type": "ClientHandler",
  "config": {
    "trustManager": {
      "type": "TrustAllManager"
    }
  }
}
```

json![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15431)Javadoc
[org.forgerock.openig.security.TrustAllManager](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/security/TrustAllManager.html)
## [](https://doc.openidentityplatform.org/openig/reference/misc-conf#UmaService)UmaService — represent an UMA resource server configuration
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15451)Description
An UmaService represents a User-Managed Access (UMA) resource server. Each service is statically registered as an OAuth 2.0 client of a single UMA authorization server.
The UmaService includes a list of resource patterns and associated actions that define the scopes for permissions to matching resources. When creating a share using the REST API described below, you specify a path matching a pattern in a resource of the UmaService.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15463)Usage
```
{
  "type": "UmaService",
  "config": {
    "protectionApiHandler": Handler reference,
    "authorizationServerUri": URI string,
    "clientId": expression,
    "clientSecret": expression,
    "resources": [ resource, ... ]
  }
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15469)Properties 

`"protectionApiHandler"`: _Handler reference, required_
    
The handler to use when interacting with the UMA authorization server to manage resource sets, such as a ClientHandler capable of making an HTTPS connection to the server.
For details, see [Handlers](https://doc.openidentityplatform.org/openig/reference/handlers-conf#handlers-conf). 

`"authorizationServerUri"`: _URI string, required_
    
The URI to the UMA authorization server. 

`"clientId"`: _expression, required_
    
An expression that evaluates to the OAuth 2.0 `client_id` registered with the UMA authorization server. 

`"clientSecret"`: _expression, required_
    
An expression that evaluates to the OAuth 2.0 `client_secret` registered with the UMA authorization server. 

`"resources"`: _array of resources, required_
    
Resource objects matching the resources the resource owner wants to share.
Each resource object has the following form:
```
{
  "pattern": resource pattern,
  "actions": [
    {
      "scopes": [ scope string, ... ],
      "condition": boolean expression
    },
    {
      ...
    }
  ]
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
Each resource pattern can be seen to represent an application, or a consistent set of endpoints that share scope definitions. The actions map each request to the associated scopes. This configuration serves to set the list of scopes in the following ways:
  1. When registering a resource set, OpenIG uses the list of actions to provide the aggregated, exhaustive list of all scopes that can be used.
  2. When responding to an initial request for a resource, OpenIG derives the scopes for the ticket based on the scopes that apply according to the request.
  3. When verifying the RPT, OpenIG checks that all required scopes are encoded in the RPT.


A description of each field follows: 

`"pattern"`: _resource pattern, required_
    
A pattern matching resources to be shared by the resource owner, such as `.`**to match any resource path, and`/photos/.`** to match paths starting with `/photos/`.
See also [Patterns(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Patterns). 

`"actions"`: _array of action objects, optional_
    
A set of actions on matching resources that the resource owner can authorize.
When granting permission, the resource owner specifies the action scope. Conditions specify what the scopes mean in concrete terms. A given scope matches a requesting party operation when the corresponding condition evaluates to `true`. 

`"scopes"`: _array of scope strings, optional_
    
Scope strings to identify permissions.
For example, `#read` (read access on a resource). 

`"condition"`: _boolean expression, required_
    
A boolean expression representing the meaning of a scope.
For example, `${request.method == 'GET'}` (true when reading a resource).
See also [Expressions(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Expressions).
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15625)The REST API for Shares
The REST API for UMA shares is exposed at a registered endpoint. OpenIG logs the paths to registered endpoints when the log level is `INFO` or finer. Look for messages such as the following in the log:
```
UMA Share endpoint available at
 '/openig/api/system/objects/router-handler/routes/00-uma/objects/umaservice/share'
```

![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
To access the endpoint over HTTP or HTTPS, prefix the path with the OpenIG scheme, host, and port to obtain a full URL, such as `http://localhost:8080/openig/api/system/objects/router-handler/routes/00-uma/objects/umaservice/share`.
The UMA REST API supports create (POST only), read, delete, and query (`_queryFilter=true` only). For an introduction to common REST APIs, see [About Common REST](https://doc.openidentityplatform.org/openig/reference/preface#sec-about-crest).
In the present implementation, OpenIG does not have a mechanism for persisting shares. When the OpenIG container stops, the shares are discarded.
A share object has the following form:
```
{
  "path": pattern,
  "pat": UMA protection API token (PAT) string,
  "id": unique identifier string,
  "resource_set_id": unique identifier string,
  "user_access_policy_uri": URI string
}
```

javascript![copy icon](https://doc.openidentityplatform.org/_/img/octicons-16.svg#view-clippy)Copied!
The fields are as follows: 

`"path"`: _pattern, required_
    
A pattern matching the path to protected resources, such as `/photos/.*`.
This pattern must match a pattern defined in the UmaService for this API.
See also [Patterns(5)](https://doc.openidentityplatform.org/openig/reference/expressions-conf#Patterns). 

`"pat"`: _PAT string, required_
    
A PAT granted by the UMA authorization server given consent by the resource owner.
In the present implementation, OpenIG has access only to the PAT, not to any refresh tokens. 

`"id"`: _unique identifier string, read-only_
    
This uniquely identifies the share. This value is set by the service when the share is created, and can be used when reading or deleting a share. 

`"resource_set_id"`: _unique identifier string, read-only_
    
This uniquely identifies the UMA resource set registered with the authorization server. This value is obtained by the service when the resource set is registered, and can be used when setting access policy permissions. 

`"user_access_policy_uri"`: _URI string, read-only_
    
This URI indicates the location on the UMA authorization server where the resource owner can set or modify access policies. This value is obtained by the service when the resource set is registered.
### [](https://doc.openidentityplatform.org/openig/reference/misc-conf#d210e15718)See Also
[User-Managed Access (UMA) Profile of OAuth 2.0](https://docs.kantarainitiative.org/uma/rec-uma-core.html)
[org.forgerock.openig.uma.UmaSharingService](https://doc.openidentityplatform.org/openig/apidocs/index.html?org/forgerock/openig/uma/UmaSharingService.html)
[Throttling Filters and Policies](https://doc.openidentityplatform.org/openig/reference/throttling-conf) [Expressions](https://doc.openidentityplatform.org/openig/reference/expressions-conf)
[© Open Identity Platform Community](https://www.openidentityplatform.org)
![](https://fonts.gstatic.com/s/i/productlogos/translate/v14/24px.svg)
Văn bản gốc
Đánh giá bản dịch này
Ý kiến phản hồi của bạn sẽ được dùng để góp phần cải thiện Google Dịch


## Content from: https://tomcat.apache.org/connectors-doc/

[![Tomcat Home](https://tomcat.apache.org/connectors-doc/images/tomcat.png)](http://tomcat.apache.org/)
[![The Apache Software Foundation](https://tomcat.apache.org/connectors-doc/images/asf-logo.svg)](https://www.apache.org/)
# The Apache Tomcat Connectors: mod_jk, ISAPI redirector, NSAPI redirector
Version 1.2.50, Aug 13 2024
## Links
  * [Docs Home](https://tomcat.apache.org/connectors-doc/index.html)


## Common HowTo
  * [Quick Start](https://tomcat.apache.org/connectors-doc/common_howto/quick.html)
  * [All About Workers](https://tomcat.apache.org/connectors-doc/common_howto/workers.html)
  * [Timeouts](https://tomcat.apache.org/connectors-doc/common_howto/timeouts.html)
  * [Load Balancing](https://tomcat.apache.org/connectors-doc/common_howto/loadbalancers.html)
  * [Reverse Proxy](https://tomcat.apache.org/connectors-doc/common_howto/proxy.html)


## Web Server HowTo
  * [Apache HTTP Server (mod_jk)](https://tomcat.apache.org/connectors-doc/webserver_howto/apache.html)
  * [Microsoft IIS (ISAPI redirector)](https://tomcat.apache.org/connectors-doc/webserver_howto/iis.html)


## Reference Guide
  * [workers.properties](https://tomcat.apache.org/connectors-doc/reference/workers.html)
  * [uriworkermap.properties](https://tomcat.apache.org/connectors-doc/reference/uriworkermap.html)
  * [Status Worker](https://tomcat.apache.org/connectors-doc/reference/status.html)
  * [Apache HTTP Server (mod_jk)](https://tomcat.apache.org/connectors-doc/reference/apache.html)
  * [Microsoft IIS (ISAPI redirector)](https://tomcat.apache.org/connectors-doc/reference/iis.html)


## AJP Protocol Reference
  * [AJPv13 (ajp13)](https://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html)
  * [AJPv13 Extension Proposal](https://tomcat.apache.org/connectors-doc/ajp/ajpv13ext.html)


## Miscellaneous Documentation
  * [Frequently Asked Questions](https://tomcat.apache.org/connectors-doc/miscellaneous/faq.html)
  * [Changelog](https://tomcat.apache.org/connectors-doc/miscellaneous/changelog.html)
  * [Current Tomcat Connectors bugs](http://issues.apache.org/bugzilla/buglist.cgi?query_format=advanced&short_desc_type=allwordssubstr&short_desc=&product=Tomcat+Connectors&long_desc_type=substring&long_desc=&bug_file_loc_type=allwordssubstr&bug_file_loc=&keywords_type=allwords&keywords=&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&emailassigned_to1=1&emailtype1=substring&email1=&emailassigned_to2=1&emailreporter2=1&emailcc2=1&emailtype2=substring&email2=&bugidtype=include&bug_id=&votes=&chfieldfrom=&chfieldto=Now&chfieldvalue=&cmdtype=doit&order=Reuse+same+sort+as+last+time&field0-0-0=noop&type0-0-0=noop&value0-0-0=)
  * [Contribute documentation](https://tomcat.apache.org/connectors-doc/miscellaneous/doccontrib.html)
  * [JK Status Ant Tasks](https://tomcat.apache.org/connectors-doc/miscellaneous/jkstatustasks.html)
  * [Reporting Tools](https://tomcat.apache.org/connectors-doc/miscellaneous/reporttools.html)


## News
  * [2024](https://tomcat.apache.org/connectors-doc/news/20240101.html)
  * [2023](https://tomcat.apache.org/connectors-doc/news/20230101.html)
  * [2020](https://tomcat.apache.org/connectors-doc/news/20200201.html)
  * [2018](https://tomcat.apache.org/connectors-doc/news/20180301.html)
  * [2016](https://tomcat.apache.org/connectors-doc/news/20160901.html)
  * [2015](https://tomcat.apache.org/connectors-doc/news/20150101.html)
  * [2014](https://tomcat.apache.org/connectors-doc/news/20140201.html)
  * [2012](https://tomcat.apache.org/connectors-doc/news/20120301.html)
  * [2011](https://tomcat.apache.org/connectors-doc/news/20110701.html)
  * [2010](https://tomcat.apache.org/connectors-doc/news/20100101.html)
  * [2009](https://tomcat.apache.org/connectors-doc/news/20090301.html)
  * [2008](https://tomcat.apache.org/connectors-doc/news/20081001.html)
  * [2007](https://tomcat.apache.org/connectors-doc/news/20070301.html)
  * [2006](https://tomcat.apache.org/connectors-doc/news/20060101.html)
  * [2005](https://tomcat.apache.org/connectors-doc/news/20050101.html)
  * [2004](https://tomcat.apache.org/connectors-doc/news/20041100.html)


## Documentation Overview
### Introduction
The **Apache Tomcat Connectors** project is part of the Tomcat project and provides web server plugins to connect web servers with Tomcat and other backends. 
The supported web servers are:
  * the Apache HTTP Server with a plugin (module) named **mod_jk**.
  * Microsoft IIS with a plugin (extension) named **ISAPI redirector** (or simply redirector).


In all cases the plugin uses a special protocol named **Apache JServ Protocol** or simply **AJP** to connect to the backend. Backends known to support AJP are Apache Tomcat, Jetty and JBoss. Although there exist 3 versions of the protocol, **ajp12** , **ajp13** , **ajp14** , most installations only use ajp13. The older ajp12 does not use persistent connections and is obsolete, the newer version ajp14 is still experimental. Sometimes ajp13 is called AJP 1.3 or AJPv13, but we will mostly use the name ajp13. 
Most features of the plugins are the same for all web servers. Some details vary on a per web server basis. The documentation and the configuration is split into common parts and web server specific parts.
down to the more detailed documentation that is available. Each available manual is described in more detail below.
### Headlines
  * [**JK-1.2.50 released**](https://tomcat.apache.org/connectors-doc/news/20240101.html)
The Apache Tomcat team is proud to announce the immediate availability of Tomcat Connectors 1.2.50 Stable. This release contains improvements and bug fixes for issues found in previous releases.
Download the [JK 1.2.50 release](https://tomcat.apache.org/download-connectors.cgi).
  * Download [previous releases](https://archive.apache.org/dist/tomcat/tomcat-connectors/) from the archives.


### Reference Guide
  * [**workers.properties**](https://tomcat.apache.org/connectors-doc/reference/workers.html)
A Tomcat worker is a Tomcat instance that is waiting to execute servlets on behalf of some web server. For example, we can have a web server such as Apache forwarding servlet requests to a Tomcat process (the worker) running behind it. 
This page contains detailed description of all workers.properties directives. 
  * [**uriworkermap.properties**](https://tomcat.apache.org/connectors-doc/reference/uriworkermap.html)
The forwarding of requests from the web server to tomcat gets configured by defining mapping rules. The so-called **uriworkermap** file is a mechanism of defining those rules. 
  * [**Status Worker**](https://tomcat.apache.org/connectors-doc/reference/status.html)
The status worker is a builtin management worker. It displays state information and can also be used to dynamically reconfigure JK. 
  * [**Apache HTTP Server (mod_jk)**](https://tomcat.apache.org/connectors-doc/reference/apache.html)
This page contains detailed description of all directives of mod_jk for the Apache HTTP Server. 
  * [**Microsoft IIS (ISAPI redirector)**](https://tomcat.apache.org/connectors-doc/reference/iis.html)
This page contains detailed description of all directives of the ISAPI redirector for Microsoft IIS. 


### Common HowTo
  * [**Quick Start**](https://tomcat.apache.org/connectors-doc/common_howto/quick.html)
This page describes the configuration files used by JK on the web server side for the 'impatient'. 
  * [**All about workers**](https://tomcat.apache.org/connectors-doc/common_howto/workers.html)
This page contains an overview about the various aspects of defining and using workers. 
  * [**Timeouts**](https://tomcat.apache.org/connectors-doc/common_howto/timeouts.html)
This page describes the possible timeout settings you can use. 
  * [**Load Balancing**](https://tomcat.apache.org/connectors-doc/common_howto/loadbalancers.html)
This page contains an introduction on load balancing with JK. 
  * [**Reverse Proxy**](https://tomcat.apache.org/connectors-doc/common_howto/proxy.html)
This page contains an introduction to reverse proxies, how JK handles this situation and how you can influence the JK proxying behaviour. 


### Webserver HowTo
These pages contain detailed descriptions of how to build and install JK for the various web servers. 
  * [**Apache HTTP Server (mod_jk)**](https://tomcat.apache.org/connectors-doc/webserver_howto/apache.html)
  * [**Microsoft IIS (ISAPI redirector)**](https://tomcat.apache.org/connectors-doc/webserver_howto/iis.html)


### AJP Protocol Reference
  * [**AJPv13**](https://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html)
This page describes the Apache JServ Protocol version 1.3 (hereafter **ajp13**). 
  * [**AJPv13 Extension Proposal**](https://tomcat.apache.org/connectors-doc/ajp/ajpv13ext.html)
This page describes an extension proposal for ajp13. 


### Miscellaneous documentation
  * [**Frequently asked questions**](https://tomcat.apache.org/connectors-doc/miscellaneous/faq.html)
  * [**Changelog**](https://tomcat.apache.org/connectors-doc/miscellaneous/changelog.html)
This page contains the detailed list of all changes made in each version of JK. 
  * [ **Current Tomcat Connectors bugs**](http://issues.apache.org/bugzilla/buglist.cgi?query_format=advanced&short_desc_type=allwordssubstr&short_desc=&product=Tomcat+Connectors&long_desc_type=substring&long_desc=&bug_file_loc_type=allwordssubstr&bug_file_loc=&keywords_type=allwords&keywords=&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&emailassigned_to1=1&emailtype1=substring&email1=&emailassigned_to2=1&emailreporter2=1&emailcc2=1&emailtype2=substring&email2=&bugidtype=include&bug_id=&votes=&chfieldfrom=&chfieldto=Now&chfieldvalue=&cmdtype=doit&order=Reuse+same+sort+as+last+time&field0-0-0=noop&type0-0-0=noop&value0-0-0=)
This is the Bugzilla Bug List related to Tomcat Connectors. 
  * [**Contribute documentation**](https://tomcat.apache.org/connectors-doc/miscellaneous/doccontrib.html)
This page describes, how to contribute to the JK documentation. 
  * [**JK Status Ant Tasks**](https://tomcat.apache.org/connectors-doc/miscellaneous/jkstatustasks.html)
This page describes ant tasks to automate JK management via the status worker. 
  * [**Reporting Tools**](https://tomcat.apache.org/connectors-doc/miscellaneous/reporttools.html)
This page contains information, on some report analysis scripts contained in the JK distribution. 


Copyright © 1999-2024, The Apache Software Foundation 


## Content from: http://tomcat.apache.org/connectors-doc/common_howto/loadbalancers.html

[![Tomcat Home](http://tomcat.apache.org/connectors-doc/images/tomcat.png)](http://tomcat.apache.org/)
[![The Apache Software Foundation](http://tomcat.apache.org/connectors-doc/images/asf-logo.svg)](https://www.apache.org/)
# The Apache Tomcat Connectors - Common HowTo
Version 1.2.50, Aug 13 2024
## Links
  * [Docs Home](http://tomcat.apache.org/connectors-doc/index.html)


## Common HowTo
  * [Quick Start](http://tomcat.apache.org/connectors-doc/common_howto/quick.html)
  * [All About Workers](http://tomcat.apache.org/connectors-doc/common_howto/workers.html)
  * [Timeouts](http://tomcat.apache.org/connectors-doc/common_howto/timeouts.html)
  * [Load Balancing](http://tomcat.apache.org/connectors-doc/common_howto/loadbalancers.html)
  * [Reverse Proxy](http://tomcat.apache.org/connectors-doc/common_howto/proxy.html)


## Web Server HowTo
  * [Apache HTTP Server (mod_jk)](http://tomcat.apache.org/connectors-doc/webserver_howto/apache.html)
  * [Microsoft IIS (ISAPI redirector)](http://tomcat.apache.org/connectors-doc/webserver_howto/iis.html)


## Reference Guide
  * [workers.properties](http://tomcat.apache.org/connectors-doc/reference/workers.html)
  * [uriworkermap.properties](http://tomcat.apache.org/connectors-doc/reference/uriworkermap.html)
  * [Status Worker](http://tomcat.apache.org/connectors-doc/reference/status.html)
  * [Apache HTTP Server (mod_jk)](http://tomcat.apache.org/connectors-doc/reference/apache.html)
  * [Microsoft IIS (ISAPI redirector)](http://tomcat.apache.org/connectors-doc/reference/iis.html)


## AJP Protocol Reference
  * [AJPv13 (ajp13)](http://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html)
  * [AJPv13 Extension Proposal](http://tomcat.apache.org/connectors-doc/ajp/ajpv13ext.html)


## Miscellaneous Documentation
  * [Frequently Asked Questions](http://tomcat.apache.org/connectors-doc/miscellaneous/faq.html)
  * [Changelog](http://tomcat.apache.org/connectors-doc/miscellaneous/changelog.html)
  * [Current Tomcat Connectors bugs](http://issues.apache.org/bugzilla/buglist.cgi?query_format=advanced&short_desc_type=allwordssubstr&short_desc=&product=Tomcat+Connectors&long_desc_type=substring&long_desc=&bug_file_loc_type=allwordssubstr&bug_file_loc=&keywords_type=allwords&keywords=&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&emailassigned_to1=1&emailtype1=substring&email1=&emailassigned_to2=1&emailreporter2=1&emailcc2=1&emailtype2=substring&email2=&bugidtype=include&bug_id=&votes=&chfieldfrom=&chfieldto=Now&chfieldvalue=&cmdtype=doit&order=Reuse+same+sort+as+last+time&field0-0-0=noop&type0-0-0=noop&value0-0-0=)
  * [Contribute documentation](http://tomcat.apache.org/connectors-doc/miscellaneous/doccontrib.html)
  * [JK Status Ant Tasks](http://tomcat.apache.org/connectors-doc/miscellaneous/jkstatustasks.html)
  * [Reporting Tools](http://tomcat.apache.org/connectors-doc/miscellaneous/reporttools.html)


## News
  * [2024](http://tomcat.apache.org/connectors-doc/news/20240101.html)
  * [2023](http://tomcat.apache.org/connectors-doc/news/20230101.html)
  * [2020](http://tomcat.apache.org/connectors-doc/news/20200201.html)
  * [2018](http://tomcat.apache.org/connectors-doc/news/20180301.html)
  * [2016](http://tomcat.apache.org/connectors-doc/news/20160901.html)
  * [2015](http://tomcat.apache.org/connectors-doc/news/20150101.html)
  * [2014](http://tomcat.apache.org/connectors-doc/news/20140201.html)
  * [2012](http://tomcat.apache.org/connectors-doc/news/20120301.html)
  * [2011](http://tomcat.apache.org/connectors-doc/news/20110701.html)
  * [2010](http://tomcat.apache.org/connectors-doc/news/20100101.html)
  * [2009](http://tomcat.apache.org/connectors-doc/news/20090301.html)
  * [2008](http://tomcat.apache.org/connectors-doc/news/20081001.html)
  * [2007](http://tomcat.apache.org/connectors-doc/news/20070301.html)
  * [2006](http://tomcat.apache.org/connectors-doc/news/20060101.html)
  * [2005](http://tomcat.apache.org/connectors-doc/news/20050101.html)
  * [2004](http://tomcat.apache.org/connectors-doc/news/20041100.html)


## Load Balancing HowTo
### Introduction
A load balancer is a worker that does not directly communicate with Tomcat. Instead it is responsible for the management of several "real" workers, called members or sub workers of the load balancer.
This management includes: 
  * Instantiating the workers in the web server. 
  * Using the worker's load balancing factor, perform weighted load balancing (distributing load according to defined strengths of the targets). 
  * Keeping requests belonging to the same session executing on the same Tomcat (session stickyness). 
  * Identifying failed Tomcat workers, suspending requests to them and instead failing over on other workers managed by the load balancer. 
  * Providing status and load metrics for the load balancer itself and all members via the status worker interface. 
  * Allowing to dynamically reconfigure load balancing via the status worker interface. 


Workers managed by the same load balancer worker are load balanced (based on their configured balancing factors and current request or session load) and also secured against failure by providing failover to other members of the same load balancer. So a single Tomcat process death will not "kill" the entire site. 
Some of the features provided by a load balancer are even interesting, when only working with a single member worker (where load balancing is not possible).
#### Basic Load Balancer Properties
A worker is configured as a load balancer by setting its worker `type` to **lb**. 
The following table specifies some properties used to configure a load balancer worker: 
  * **balance_workers** is a comma separated list of names of the member workers of the load balancer. These workers are typically of type **ajp13**. The member workers do not need to appear in the `worker.list` property themselves, adding the load balancer to it suffices.
  * **sticky_session** specifies whether requests with SESSION ID's should be routed back to the same Tomcat instance that created the session. You can set sticky_session to **false** when Tomcat is using a session manager which can share session data across multiple instances of Tomcat - or if your application is stateless. By default sticky_session is set to **true**.
  * **lbfactor** can be added to each member worker to configure individual strengths for the members. A higher `lbfactor` will lead to more requests being balanced to that worker. The factors must be given by integers and the load will be distributed proportional to the factors given. Higher factors lead to more requests.


```
# The load balancer worker balance1 will distribute
# load to the members worker1 and worker2
worker.balance1.type=lb
worker.balance1.balance_workers=worker1, worker2
worker.worker1.type=ajp13
worker.worker1.host=myhost1
worker.worker1.port=8009
worker.worker2.type=ajp13
worker.worker1.host=myhost2
worker.worker1.port=8009

```

Session stickyness is not implemented using a tracking table for sessions. Instead each Tomcat instance gets an individual name and adds its name at the end of the session id. When the load balancer sees a session id, it finds the name of the Tomcat instance and sends the request via the correct member worker. For this to work you must set the name of the Tomcat instances as the value of the `jvmRoute` attribute in the Engine element of each Tomcat's server.xml. The name of the Tomcat needs to be equal to the name of the corresponding load balancer member. In the above example, Tomcat on host "myhost1" needs `jvmRoute="worker1"`, Tomcat on host "myhost2" needs `jvmRoute="worker2"`. 
For a complete reference of all load balancer configuration attributes, please consult the worker [reference](http://tomcat.apache.org/connectors-doc/reference/workers.html). 
#### Advanced Load Balancer Worker Properties
The load balancer supports complex topologies and failover configurations. Using the member attribute `distance` you can group members. The load balancer will always send a request to a member of lowest distance. Only when all of those are broken, it will balance to the members of the next higher configured distance. This allows to define priorities between Tomcat instances in different data center locations. 
When working with shared sessions, either by using session replication or a persisting session manager (e.g. via a database), one often splits up the Tomcat farm into replication groups. In case of failure of a member, the load balancer needs to know, which other members share the session. This is configured using the `domain` attribute. All workers with the same domain are assumed to share the sessions.
For maintenance purposes you can tell the load balancer to not allow any new sessions on some members, or even not use them at all. This is controlled by the member attribute `activation`. The value **Active** allows normal use of a member, **disabled** will not create new sessions on it, but still allow sticky requests, and **stopped** will no longer send any requests to the member. Switching the activation from "active" to "disabled" some time before maintenance will drain the sessions on the worker and minimize disruption. Depending on the usage pattern of the application, draining will take from minutes to hours. Switching the worker to stopped immediately before maintenance will reduce logging of false errors by mod_jk.
Finally you can also configure hot spare workers by using `activation` set to **disabled** in combination with the attribute `redirect` added to the other workers:
```
# The advanced router LB worker
worker.list=router
worker.router.type=lb
worker.router.balance_workers=worker1,worker2
# Define the first member worker
worker.worker1.type=ajp13
worker.worker1.host=myhost1
worker.worker1.port=8009
# Define preferred failover node for worker1
worker.worker1.redirect=worker2
# Define the second member worker
worker.worker2.type=ajp13
worker.worker2.host=myhost2
worker.worker2.port=8009
# Disable worker2 for all requests except failover
worker.worker2.activation=disabled

```

The `redirect` flag on worker1 tells the load balancer to redirect the requests to worker2 in case that worker1 has a problem. In all other cases worker2 will not receive any requests, thus acting like a hot standby. 
A final note about setting `activation` to **disabled** : The session id coming with a request is send either as part of the request URL (`;jsessionid=...`) or via a cookie. When using bookmarks or browsers that are running since a long time, it is possible to send a request carrying an old and invalid session id pointing at a disabled member. Since the load balancer does not have a list of valid sessions, it will forward the request to the disabled member. Thus draining takes longer than expected. To handle such cases, you can add a Servlet filter to your web application, which checks the request attribute `JK_LB_ACTIVATION`. This attribute contains one of the strings "ACT", "DIS" or "STP". If you detect "DIS" and the session for the request is no longer active, delete the session cookie and redirect using a self-referential URL. The redirected request will then no longer carry session information and thus the load balancer will not send it to the disabled worker. The request attribute `JK_LB_ACTIVATION` has been added in version 1.2.32.
#### Status Worker properties
The status worker does not communicate with Tomcat. Instead it is responsible for the worker management. It is especially useful when combined with load balancer workers. 
```
# Add the status worker to the worker list
worker.list=jkstatus
# Define a 'jkstatus' worker using status
worker.jkstatus.type=status

```

Next thing is to mount the requests to the jkstatus worker. For Apache HTTP Servers use:
```
# Add the jkstatus mount point
JkMount /jkmanager/* jkstatus 

```

To obtain a higher level of security use the:
```
# Enable the JK manager access from localhost only
<Location /jkmanager/>
 JkMount jkstatus
 Require ip 127.0.0.1
</Location>

```

Copyright © 1999-2024, The Apache Software Foundation 


## Content from: https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html

[![Tomcat Home](https://tomcat.apache.org/tomcat-10.1-doc/images/tomcat.png)](https://tomcat.apache.org/)
[![The Apache Software Foundation](https://tomcat.apache.org/tomcat-10.1-doc/images/asf-logo.svg)](https://www.apache.org/)
# Apache Tomcat 10 Configuration Reference
Version 10.1.52, Jan 23 2026
## Links
  * [Docs Home](https://tomcat.apache.org/tomcat-10.1-doc/index.html)
  * [Config Ref. Home](https://tomcat.apache.org/tomcat-10.1-doc/config/index.html)
  * [FAQ](https://cwiki.apache.org/confluence/display/TOMCAT/FAQ)
  * [User Comments](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#comments_section)


## Top Level Elements
  * [Server](https://tomcat.apache.org/tomcat-10.1-doc/config/server.html)
  * [Service](https://tomcat.apache.org/tomcat-10.1-doc/config/service.html)


## Executors
  * [Executor](https://tomcat.apache.org/tomcat-10.1-doc/config/executor.html)


## Connectors
  * [HTTP/1.1](https://tomcat.apache.org/tomcat-10.1-doc/config/http.html)
  * [HTTP/2](https://tomcat.apache.org/tomcat-10.1-doc/config/http2.html)
  * [AJP](https://tomcat.apache.org/tomcat-10.1-doc/config/ajp.html)


## Containers
  * [Context](https://tomcat.apache.org/tomcat-10.1-doc/config/context.html)
  * [Engine](https://tomcat.apache.org/tomcat-10.1-doc/config/engine.html)
  * [Host](https://tomcat.apache.org/tomcat-10.1-doc/config/host.html)
  * [Cluster](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html)


## Nested Components
  * [CookieProcessor](https://tomcat.apache.org/tomcat-10.1-doc/config/cookie-processor.html)
  * [CredentialHandler](https://tomcat.apache.org/tomcat-10.1-doc/config/credentialhandler.html)
  * [Global Resources](https://tomcat.apache.org/tomcat-10.1-doc/config/globalresources.html)
  * [JarScanner](https://tomcat.apache.org/tomcat-10.1-doc/config/jar-scanner.html)
  * [JarScanFilter](https://tomcat.apache.org/tomcat-10.1-doc/config/jar-scan-filter.html)
  * [Listeners](https://tomcat.apache.org/tomcat-10.1-doc/config/listeners.html)
  * [Loader](https://tomcat.apache.org/tomcat-10.1-doc/config/loader.html)
  * [Manager](https://tomcat.apache.org/tomcat-10.1-doc/config/manager.html)
  * [Realm](https://tomcat.apache.org/tomcat-10.1-doc/config/realm.html)
  * [Resources](https://tomcat.apache.org/tomcat-10.1-doc/config/resources.html)
  * [SessionIdGenerator](https://tomcat.apache.org/tomcat-10.1-doc/config/sessionidgenerator.html)
  * [Valve](https://tomcat.apache.org/tomcat-10.1-doc/config/valve.html)


## Cluster Elements
  * [Cluster](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html)
  * [Manager](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-manager.html)
  * [Channel](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-channel.html)
  * [Channel/Membership](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-membership.html)
  * [Channel/Sender](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-sender.html)
  * [Channel/Receiver](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-receiver.html)
  * [Channel/Interceptor](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-interceptor.html)
  * [Valve](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-valve.html)
  * [Deployer](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-deployer.html)
  * [ClusterListener](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-listener.html)


## web.xml
  * [Filter](https://tomcat.apache.org/tomcat-10.1-doc/config/filter.html)


## Other
  * [Runtime attributes](https://tomcat.apache.org/tomcat-10.1-doc/config/runtime-attributes.html)
  * [System properties](https://tomcat.apache.org/tomcat-10.1-doc/config/systemprops.html)
  * [Jakarta Authentication](https://tomcat.apache.org/tomcat-10.1-doc/config/jaspic.html)


## The Cluster object
### Table of Contents
  * [Introduction](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Introduction)
  * [Security](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Security)
  * [Engine vs Host placement](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Engine_vs_Host_placement)
  * [Context Attribute Replication](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Context_Attribute_Replication)
  * [Nested Components](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Nested_Components)
  * [Attributes](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#Attributes)
    1. [SimpleTcpCluster Attributes](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster.html#SimpleTcpCluster_Attributes)


### Introduction
The tomcat cluster implementation provides session replication, context attribute replication and cluster wide WAR file deployment. While the `Cluster` configuration is fairly complex, the default configuration will work for most people out of the box. 
The Tomcat Cluster implementation is very extensible, and hence we have exposed a myriad of options, making the configuration seem like a lot, but don't lose faith, instead you have a tremendous control over what is going on.
### Security
The cluster implementation is written on the basis that a secure, trusted network is used for all of the cluster related network traffic. It is not safe to run a cluster on a insecure, untrusted network.
There are many options for providing a secure, trusted network for use by a Tomcat cluster. These include:
  * private LAN
  * a Virtual Private Network (VPN)
  * IPSEC


The [EncryptInterceptor](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-interceptor.html#org.apache.catalina.tribes.group.interceptors.EncryptInterceptor_Attributes) provides confidentiality and integrity protection but it does not protect against all risks associated with running a Tomcat cluster on an untrusted network, particularly DoS attacks.
### Engine vs Host placement
You can place the `<Cluster>` element inside either the `<Engine>` container or the `<Host>` container. Placing it in the engine, means that you will support clustering in all virtual hosts of Tomcat, and share the messaging component. When you place the `<Cluster>` inside the `<Engine>` element, the cluster will append the host name of each session manager to the managers name so that two contexts with the same name but sitting inside two different hosts will be distinguishable. 
### Context Attribute Replication
To configure context attribute replication, simply do this by swapping out the context implementation used for your application context.
```
<Context className="org.apache.catalina.ha.context.ReplicatedContext"/>
```

This context extends the Tomcat `StandardContext[](https://tomcat.apache.org/tomcat-10.1-doc/config/context.html)` so all the options from the [base implementation](https://tomcat.apache.org/tomcat-10.1-doc/config/context.html) are valid. 
### Nested Components
**[Manager](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-manager.html):** The session manager element identifies what kind of session manager is used in this cluster implementation. This manager configuration is identical to the one you would use in a regular `<Context>[](https://tomcat.apache.org/tomcat-10.1-doc/config/context.html#Nested_Components)` configuration. The default value is the `org.apache.catalina.ha.session.DeltaManager` that is closely coupled with the `SimpleTcpCluster` implementation. Other managers like the `org.apache.catalina.ha.session.BackupManager` are/could be loosely coupled and don't rely on the `SimpleTcpCluster` for its data replication. 
**[Channel](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-channel.html):** The Channel and its sub components are all part of the IO layer for the cluster group, and is a module in it's own that we have nick named "Tribes" Any configuring and tuning of the network layer, the messaging and the membership logic will be done in the channel and its nested components. You can always find out more about [Apache Tribes](https://tomcat.apache.org/tomcat-10.1-doc/tribes/introduction.html)
**[Valve](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-valve.html):** The Tomcat Cluster implementation uses `Tomcat Valves[](https://tomcat.apache.org/tomcat-10.1-doc/config/valve.html)` to track when requests enter and exit the servlet container. It uses these valves to be able to make intelligent decisions on when to replicate data, which is always at the end of a request. 
**[Deployer](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-deployer.html):** The Deployer component is the Tomcat Farm Deployer. It allows you to deploy and undeploy applications cluster wide. 
**[ClusterListener](https://tomcat.apache.org/tomcat-10.1-doc/config/cluster-listener.html):** ClusterListener's are used to track messages sent and received using the `SimpleTcpCluster`. If you wish to track messages, you can add a listener here, or you can add a valve to the channel object. 
### Attributes
#### SimpleTcpCluster Attributes
Attribute |  Description   
---|---  
**`className`**|  The main cluster class, currently only one is available, `org.apache.catalina.ha.tcp.SimpleTcpCluster`  
**`channelSendOptions`**|  The Tribes channel send options. This option is used for all messages sent through the SimpleTcpCluster. The value may be specified either as an integer (add values to use multiple flags) or using a comma-separate list of the human-readable option names. Human-readable names are translated to their integer values on startup. The different values offer a tradeoff between throughput on the sending node and the reliability of replication should the sending or receiving node(s) fail. The supported values are: 

`byte_message`, `byte` or `1`
    The message is a pure byte message and no marshaling or unmarshalling will be performed 

`use_ack` or `2`
    The message is sent and an ACK is received when the message has been received by the recipient. If no ack is received, the message is not considered successful. 

`synchronized_ack`, `sync` or `4`
    Has no effect unless `use_ack` is set. The message is sent and an ACK is received when the message has been received and processed by the recipient. If no ack is received, the message is not considered successful. 

`asynchronous`, `async` or `8`
    The message will be placed on a queue and sent by a separate thread. It is possible for update messages for a session to be processed by the receiving node in a different order to the order in which they were sent. 

`secure` or `16`
    Not implemented. Has no effect if used. 

`udp` or `32`
    The message will be sent using UDP instead of TCP. 

`multicast` or `64`
    Not implemented. Messages will not be sent if used. The default value is `8` (`async`).  
`channelStartOptions`|  Sets the start and stop flags for the <Channel> object used by the cluster. The default is `Channel.DEFAULT` which starts all the channel services, such as sender, receiver, membership sender and membership receiver. The following flags are available today: ```
Channel.DEFAULT = Channel.SND_RX_SEQ (1) |
         Channel.SND_TX_SEQ (2) |
         Channel.MBR_RX_SEQ (4) |
         Channel.MBR_TX_SEQ (8);
```
When using the static membership service `org.apache.catalina.tribes.membership.StaticMembershipService` you must ensure that this attribute is configured to use the default value.  
`heartbeatBackgroundEnabled`|  Flag whether invoke channel heartbeat at container background thread. Default value is false. Enable this flag don't forget to disable the channel heartbeat thread.   
`notifyLifecycleListenerOnFailure`|  Flag whether notify LifecycleListeners if all ClusterListener couldn't accept channel message. Default value is false.   
Copyright © 1999-2026, The Apache Software Foundation Apache Tomcat, Tomcat, Apache, the Apache Tomcat logo and the Apache logo are either registered trademarks or trademarks of the Apache Software Foundation. 


## Content from: http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html

[![
  The Apache Tomcat Servlet/JSP Container
 ](http://tomcat.apache.org/tomcat-7.0-doc/images/tomcat.gif)](https://tomcat.apache.org/)| 
# Apache Tomcat 7
Version 7.0.109, Apr 22 2021| [![Apache Logo](http://tomcat.apache.org/tomcat-7.0-doc/images/asf-logo.svg)](http://www.apache.org/)  
---|---|---  
**Links**
  * [Docs Home](http://tomcat.apache.org/tomcat-7.0-doc/index.html)
  * [Config Ref. Home](http://tomcat.apache.org/tomcat-7.0-doc/config/index.html)
  * [FAQ](https://wiki.apache.org/tomcat/FAQ)
  * [User Comments](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#comments_section)

**Top Level Elements**
  * [Server](http://tomcat.apache.org/tomcat-7.0-doc/config/server.html)
  * [Service](http://tomcat.apache.org/tomcat-7.0-doc/config/service.html)

**Executors**
  * [Executor](http://tomcat.apache.org/tomcat-7.0-doc/config/executor.html)

**Connectors**
  * [HTTP](http://tomcat.apache.org/tomcat-7.0-doc/config/http.html)
  * [AJP](http://tomcat.apache.org/tomcat-7.0-doc/config/ajp.html)

**Containers**
  * [Context](http://tomcat.apache.org/tomcat-7.0-doc/config/context.html)
  * [Engine](http://tomcat.apache.org/tomcat-7.0-doc/config/engine.html)
  * [Host](http://tomcat.apache.org/tomcat-7.0-doc/config/host.html)
  * [Cluster](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster.html)

**Nested Components**
  * [Global Resources](http://tomcat.apache.org/tomcat-7.0-doc/config/globalresources.html)
  * [JarScanner](http://tomcat.apache.org/tomcat-7.0-doc/config/jar-scanner.html)
  * [Listeners](http://tomcat.apache.org/tomcat-7.0-doc/config/listeners.html)
  * [Loader](http://tomcat.apache.org/tomcat-7.0-doc/config/loader.html)
  * [Manager](http://tomcat.apache.org/tomcat-7.0-doc/config/manager.html)
  * [Realm](http://tomcat.apache.org/tomcat-7.0-doc/config/realm.html)
  * [Resources](http://tomcat.apache.org/tomcat-7.0-doc/config/resources.html)
  * [SessionIdGenerator](http://tomcat.apache.org/tomcat-7.0-doc/config/sessionidgenerator.html)
  * [Valve](http://tomcat.apache.org/tomcat-7.0-doc/config/valve.html)

**Cluster Elements**
  * [Cluster](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster.html)
  * [Manager](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html)
  * [Channel](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-channel.html)
  * [Channel/Membership](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-membership.html)
  * [Channel/Sender](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-sender.html)
  * [Channel/Receiver](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-receiver.html)
  * [Channel/Interceptor](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-interceptor.html)
  * [Valve](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-valve.html)
  * [Deployer](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-deployer.html)
  * [ClusterListener](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-listener.html)

**web.xml**
  * [Filter](http://tomcat.apache.org/tomcat-7.0-doc/config/filter.html)

**Other**
  * [System properties](http://tomcat.apache.org/tomcat-7.0-doc/config/systemprops.html)

| 
# The ClusterManager object
| **Table of Contents**  
---  
>   * [Introduction](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#Introduction)
>   * [The <Manager>](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#The_<Manager>)
>   * [Attributes](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#Attributes)
>     1. [Common Attributes](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#Common_Attributes)
>     2. [org.apache.catalina.ha.session.DeltaManager Attributes](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#org.apache.catalina.ha.session.DeltaManager_Attributes)
>     3. [org.apache.catalina.ha.session.BackupManager Attributes](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#org.apache.catalina.ha.session.BackupManager_Attributes)
>   * [Nested Components](http://tomcat.apache.org/tomcat-7.0-doc/config/cluster-manager.html#Nested_Components)
> 
  
**Introduction**  
---  
> A cluster manager is an extension to Tomcat's session manager interface, `org.apache.catalina.Manager`. A cluster manager must implement the `org.apache.catalina.ha.ClusterManager` and is solely responsible for how the session is replicated. There are currently two different managers, the `org.apache.catalina.ha.session.DeltaManager` replicates deltas of session data to all members in the cluster. This implementation is proven and works very well, but has a limitation as it requires the cluster members to be homogeneous, all nodes must deploy the same applications and be exact replicas. The `org.apache.catalina.ha.session.BackupManager` also replicates deltas but only to one backup node. The location of the backup node is known to all nodes in the cluster. It also supports heterogeneous deployments, so the manager knows at what locations the web application is deployed.  
**The <Manager>**  
---  
> The `<Manager>` element defined inside the `<Cluster>` element is the template defined for all web applications that are marked `<distributable/>` in their `web.xml` file. However, you can still override the manager implementation on a per web application basis, by putting the `<Manager>` inside the `<Context>` element either in the `context.xml[](http://tomcat.apache.org/tomcat-7.0-doc/config/context.html)` file or the `server.xml[](http://tomcat.apache.org/tomcat-7.0-doc/config/index.html)` file.  
**Attributes**  
---  
> | **Common Attributes**  
> ---  
>> | Attribute| Description  
>> ---|---  
>> **`className`**  
>> `name`| **The name of this cluster manager, the name is used to identify a session manager on a node. The name might get modified by the`Cluster` element to make it unique in the container.**  
>> `notifyListenersOnReplication`|  Set to `true` if you wish to have session listeners notified when session attributes are being replicated or removed across Tomcat nodes in the cluster.   
>> `expireSessionsOnShutdown`|  When a web application is being shutdown, Tomcat issues an expire call to each session to notify all the listeners. If you wish for all sessions to expire on all nodes when a shutdown occurs on one node, set this value to `true`. Default value is `false`.   
>> `maxInactiveInterval`|  **Deprecated** : This should be configured via the Context. The initial maximum time interval, in seconds, between client requests before a session is invalidated. A negative value will result in sessions never timing out. If the attribute is not provided, a default of 1800 seconds (30 minutes) is used. This attribute provides the initial value whenever a new session is created, but the interval may be dynamically varied by a servlet via the `setMaxInactiveInterval` method of the `HttpSession` object.  
>> `sessionIdLength`|  The length of session ids created by this Manager, measured in bytes, excluding subsequent conversion to a hexadecimal string and excluding any JVM route information used for load balancing. The default is 16. You should set the length on a nested **SessionIdGenerator** element instead.  
>> `processExpiresFrequency`|  Frequency of the session expiration, and related manager operations. Manager operations will be done once for the specified amount of backgroundProcess calls (i.e., the lower the amount, the more often the checks will occur). The minimum value is 1, and the default value is 6.   
>> `secureRandomClass`|  Name of the Java class that extends `java.security.SecureRandom` to use to generate session IDs. If not specified, the default value is `java.security.SecureRandom`.  
>> `secureRandomProvider`|  Name of the provider to use to create the `java.security.SecureRandom` instances that generate session IDs. If an invalid algorithm and/or provider is specified, the Manager will use the platform default provider and the default algorithm. If not specified, the platform default provider will be used.  
>> `secureRandomAlgorithm`|  Name of the algorithm to use to create the `java.security.SecureRandom` instances that generate session IDs. If an invalid algorithm and/or provider is specified, the Manager will use the platform default provider and the default algorithm. If not specified, the default algorithm of SHA1PRNG will be used. If the default algorithm is not supported, the platform default will be used. To specify that the platform default should be used, do not set the secureRandomProvider attribute and set this attribute to the empty string.  
>> `recordAllActions`|  Flag whether send all actions for session across Tomcat cluster nodes. If set to false, if already done something to the same attribute, make sure don't send multiple actions across Tomcat cluster nodes. In that case, sends only the actions that have been added at last. Default is `false`.  
> **org.apache.catalina.ha.session.DeltaManager Attributes**  
> ---  
>> | Attribute| Description  
>> ---|---  
>> `expireSessionsOnShutdown`|  When a web application is being shutdown, Tomcat issues an expire call to each session to notify all the listeners. If you wish for all sessions to expire on all nodes when a shutdown occurs on one node, set this value to `true`. Default value is `false`.   
>> `maxActiveSessions`|  The maximum number of active sessions that will be created by this Manager, or -1 (the default) for no limit. For this manager, all sessions are counted as active sessions irrespective if whether or not the current node is the primary node for the session.   
>> `notifySessionListenersOnReplication`|  Set to `true` if you wish to have session listeners notified when sessions are created and expired across Tomcat nodes in the cluster.   
>> `notifyContainerListenersOnReplication`|  Set to `true` if you wish to have container listeners notified across Tomcat nodes in the cluster.   
>> `stateTransferTimeout`|  The time in seconds to wait for a session state transfer to complete from another node when a node is starting up. Default value is `60` seconds.   
>> `sendAllSessions`|  Flag whether send sessions as split blocks. If set to `true`, send all sessions as one big block. If set to `false`, send sessions as split blocks. Default value is `true`.   
>> `sendAllSessionsSize`|  The number of sessions in a session block message. This value is effective only when `sendAllSessions` is `false`. Default is `1000`.   
>> `sendAllSessionsWaitTime`|  Wait time between sending of session block messages. This value is effective only when `sendAllSessions` is `false`. Default is `2000` milliseconds.   
>> `sessionAttributeNameFilter`|  A regular expression used to filter which session attributes will be replicated. An attribute will only be replicated if its name matches this pattern. If the pattern is zero length or `null`, all attributes are eligible for replication. The pattern is anchored so the session attribute name must fully match the pattern. As an example, the value `(userName|sessionHistory)` will only replicate the two session attributes named `userName` and `sessionHistory`. If not specified, the default value of `null` will be used.  
>> `sessionAttributeValueClassNameFilter`|  A regular expression used to filter which session attributes will be replicated. An attribute will only be replicated if the implementation class name of the value matches this pattern. If the pattern is zero length or `null`, all attributes are eligible for replication. The pattern is anchored so the fully qualified class name must fully match the pattern. If not specified, the default value of `null` will be used unless a `SecurityManager` is enabled in which case the default will be `java\\.lang\\.(?:Boolean|Integer|Long|Number|String)`.  
>> `stateTimestampDrop`|  When this node sends a `GET_ALL_SESSIONS` message to other node, all session messages that are received as a response are queued. If this attribute is set to `true`, the received session messages (except any `GET_ALL_SESSIONS` sent by other nodes) are filtered by their timestamp. A message is dropped if it is not a `GET_ALL_SESSIONS` message and its timestamp is earlier than the timestamp of our `GET_ALL_SESSIONS` message. If set to `false`, all queued session messages are handled. Default is `true`.   
>> `warnOnSessionAttributeFilterFailure`|  If **sessionAttributeNameFilter** or **sessionAttributeValueClassNameFilter** blocks an attribute, should this be logged at `WARN` level? If `WARN` level logging is disabled then it will be logged at `DEBUG`. The default value of this attribute is `false` unless a `SecurityManager` is enabled in which case the default will be `true`.  
> **org.apache.catalina.ha.session.BackupManager Attributes**  
> ---  
>> | Attribute| Description  
>> ---|---  
>> `mapSendOptions`|  The backup manager uses a replicated map, this map is sending and receiving messages. You can setup the flag for how this map is sending messages, the default value is `6`(synchronous). Note that if you use asynchronous messaging it is possible for update messages for a session to be processed by the receiving node in a different order to the order in which they were sent.   
>> `maxActiveSessions`|  The maximum number of active sessions that will be created by this Manager, or -1 (the default) for no limit. For this manager, only sessions where the current node is the primary node for the session are considered active sessions.   
>> `rpcTimeout`|  Timeout for RPC message used for broadcast and transfer state from another map. Default value is `15000` milliseconds.   
>> `sessionAttributeNameFilter`|  A regular expression used to filter which session attributes will be replicated. An attribute will only be replicated if its name matches this pattern. If the pattern is zero length or `null`, all attributes are eligible for replication. The pattern is anchored so the session attribute name must fully match the pattern. As an example, the value `(userName|sessionHistory)` will only replicate the two session attributes named `userName` and `sessionHistory`. If not specified, the default value of `null` will be used.  
>> `sessionAttributeValueClassNameFilter`|  A regular expression used to filter which session attributes will be replicated. An attribute will only be replicated if the implementation class name of the value matches this pattern. If the pattern is zero length or `null`, all attributes are eligible for replication. The pattern is anchored so the fully qualified class name must fully match the pattern. If not specified, the default value of `null` will be used unless a `SecurityManager` is enabled in which case the default will be `java\\.lang\\.(?:Boolean|Integer|Long|Number|String)`.  
>> `terminateOnStartFailure`|  Set to true if you wish to terminate replication map when replication map fails to start. If replication map is terminated, associated context will fail to start. If you set this attribute to false, replication map does not end. It will try to join the map membership in the heartbeat. Default value is `false` .   
>> `warnOnSessionAttributeFilterFailure`|  If **sessionAttributeNameFilter** or **sessionAttributeValueClassNameFilter** blocks an attribute, should this be logged at `WARN` level? If `WARN` level logging is disabled then it will be logged at `DEBUG`. The default value of this attribute is `false` unless a `SecurityManager` is enabled in which case the default will be `true`.  
>> `accessTimeout`|  The timeout for a ping message. If a remote map does not respond within this timeout period, its regarded as disappeared. Default value is `5000` milliseconds.   
**Nested Components**  
---  
> ### All Manager Implementations
> All Manager implementations allow nesting of a **< SessionIdGenerator>** element. It defines the behavior of session id generation. All implementations of the [SessionIdGenerator](http://tomcat.apache.org/tomcat-7.0-doc/config/sessionidgenerator.html) allow the following attributes:  | Attribute| Description  
> ---|---  
> `sessionIdLength`|  The length of the session ID may be changed with the **sessionIdLength** attribute.   
_Copyright © 1999-2021, Apache Software Foundation_


## Content from: http://www.eclipse.org/jetty/documeation/current/session-clustering-jdbc.html

## HTTP ERROR 404 Not Found
URI:| https://jetty.org/documeation/current/session-clustering-jdbc.html  
---|---  
STATUS:| 404  
MESSAGE:| Not Found  
[Powered by Jetty:// 12.1.6](https://jetty.org/)


## Content from: http://www.eclipse.org/jetty/documentation/current/session-clustering-mongodb.html

[![Eclipse Jetty](http://www.eclipse.org/jetty/documentation/_/img/jetty-logo.svg)](https://jetty.org) [Eclipse Jetty](https://jetty.org)
[Documentation](http://www.eclipse.org/jetty/documentation/current/index.html) [Support](http://www.eclipse.org/jetty/documentation/support.html) [Security](http://www.eclipse.org/jetty/documentation/security.html) [Download](http://www.eclipse.org/jetty/documentation/download.html)
[Links](http://www.eclipse.org/jetty/documentation/current/session-clustering-mongodb.html)
[Source Code](https://github.com/jetty/jetty.project) [Issues](https://github.com/jetty/jetty.project/issues) [Contributing](http://www.eclipse.org/jetty/documentation/current/contribution-guide/index.html)
Jetty Documentation
  * [Contribution Guide](http://www.eclipse.org/jetty/documentation/current/contribution-guide/index.html)
  * [Eclipse Jetty](http://www.eclipse.org/jetty/documentation/current/jetty/12.1/index.html)
    * [12.1](http://www.eclipse.org/jetty/documentation/current/jetty/12.1/index.html)
    * [12](http://www.eclipse.org/jetty/documentation/current/jetty/12/index.html)
    * [11](http://www.eclipse.org/jetty/documentation/current/jetty/11/index.html)
    * [10](http://www.eclipse.org/jetty/documentation/current/jetty/10/index.html)


[](http://www.eclipse.org/jetty/documentation/index.html)
  * [Jetty Documentation](http://www.eclipse.org/jetty/documentation/current/index.html)


[Edit this Page](https://github.com/jetty/jetty.website/edit/main/docs-home/modules/ROOT/pages/index.adoc)
# Jetty Documentation
Jetty Documentation is split by major versions. Follow the links below for the version of Jetty you are using. Documentation for earlier releases is available in Maven Central.
Release Version | Resources  
---|---  
**[Eclipse Jetty 12.1](http://www.eclipse.org/jetty/documentation/current/jetty/12.1/index.html)** | [api](https://javadoc.jetty.org/jetty-12.1/index.html) / [source](https://github.com/eclipse/jetty.project/tree/jetty-12.1.x)  
**[Eclipse Jetty 12](http://www.eclipse.org/jetty/documentation/current/jetty/12/index.html)** | [api](https://javadoc.jetty.org/jetty-12/index.html) / [source](https://github.com/eclipse/jetty.project/tree/jetty-12.0.x)  
**[Eclipse Jetty 11](http://www.eclipse.org/jetty/documentation/current/jetty/11/index.html)** | [api](https://javadoc.jetty.org/jetty-11/index.html) / [source](https://github.com/eclipse/jetty.project/tree/jetty-11.0.x)  
**[Eclipse Jetty 10](http://www.eclipse.org/jetty/documentation/current/jetty/10/index.html)** | [api](https://javadoc.jetty.org/jetty-10/index.html) / [source](https://github.com/eclipse/jetty.project/tree/jetty-10.0.x)  
[![Eclipse Jetty](http://www.eclipse.org/jetty/documentation/_/img/jetty-logo.svg)](https://jetty.org)
  * [Docs](http://www.eclipse.org/jetty/documentation/current/index.html)
  * [Support](http://www.eclipse.org/jetty/documentation/support.html)
  * Lists: [users](http://dev.eclipse.org/mhonarc/lists/jetty-users/maillist.html) - [dev](http://dev.eclipse.org/mhonarc/lists/jetty-dev/maillist.html)
  * [Source](https://github.com/eclipse/jetty.project)


[![X logo](http://www.eclipse.org/jetty/documentation/_/img/x-logo.svg)@JettyProject](https://twitter.com/JettyProject "Follow us on X")
Copyright © 2008-2026 Webtide
The [UI for this site](https://github.com/jetty/jetty.website) is derived from the Antora default UI and is licensed under the MPL-2.0 license. Several icons are imported from [Octicons](https://primer.style/octicons/) and are licensed under the MIT license.
Eclipse Jetty® is a trademarks of the Eclipse Foundation, Inc.
This project is made possible by Webtide. Additional thanks to the [Eclipse Foundation](https://eclipse.org) for hosting this project.
[![Webtide Logo](http://www.eclipse.org/jetty/documentation/_/img/webtide-logo.png)](https://webtide.com "Development led by Webtide") [![Jetbrains Logo](http://www.eclipse.org/jetty/documentation/_/img/jetbrains.svg)](https://jetbrains.com/idea "IntelliJ IDEA integration provided by JetBrains")
Authored in [AsciiDoc](https://asciidoc.org).Produced by [Antora](https://antora.org) and [Asciidoctor](https://asciidoctor.org).
