## [Unreleased]

## [0.7.0] (2022-11-28)
### Changed
 * Upgrade dependencies
 * Clean up some docs
 * some internal code cleaning
 * ** Breaking **  Support Elixir 1.11 and above
## [0.6.0] (2021-05-24)
### Changed
 * Upgrade dependencies
 * Adds the service name to the token identified into the conn under the key simple_token_auth_service
 * **Potentially Breaking** Depend on `persistent_term` for caching the config which requires OTP 21.2 minimum (http://erlang.org/doc/man/persistent_term.html)

## [0.5.0] (2020-07-07)
### Changed
 * Add supports for service specific token and log the service name in the metadata

For prior versions, please look at the commit log