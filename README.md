[logo]: https://www.authelia.com/images/branding/title.png "Authelia"
[![alt text][logo]](https://www.authelia.com/)

# authelia/base
[![Docker Pulls](https://img.shields.io/docker/pulls/authelia/base.svg)](https://hub.docker.com/r/authelia/base/) [![Docker Stars](https://img.shields.io/docker/stars/authelia/base.svg)](https://hub.docker.com/r/authelia/base/)

This custom image is based on a `FROM scratch` base with [Chisel](https://github.com/canonical/chisel) to provide glibc components and required packages for Authelia's docker deployment.

The image will be re-built under the following scenarios:
1. Daily for security updates
2. Triggered before any versioned/tagged Authelia builds
3. Updates are made to the base images

## Information

This container includes the bare minimum packages for Authelia to function in a Docker deployment:

* busybox
* ca-certificates
* su-exec
* tzdata
* wget

## Version
- **15/10/2024:** Initial release