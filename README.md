<p align="center">
  <img src="https://www.authelia.com/images/authelia-title.png" width="350" title="Authelia">
</p>

<p align="center">
  <a href="https://buildkite.com/authelia/baseimage"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fbuildkite%2F2acff7529b3af230859a7372c0b3d43d135b4186d43a3cf686%2Fmaster.json&query=%24.message&label=build&logo=buildkite&logoColor=%2314cc80&mode=dark&size=sm&variant=outline"><img alt="Build" src="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fbuildkite%2F2acff7529b3af230859a7372c0b3d43d135b4186d43a3cf686%2Fmaster.json&query=%24.message&label=build&logo=buildkite&logoColor=%2314cc80&mode=light&size=sm&variant=outline"></picture></a>
  <a href="https://www.apache.org/licenses/LICENSE-2.0"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/authelia/baseimage/license.svg?logo=apache&logoColor=%23d22128&mode=dark&size=sm&variant=outline"><img alt="License" src="https://shieldcn.dev/github/authelia/baseimage/license.svg?logo=apache&logoColor=%23d22128&mode=light&size=sm&variant=outline"></picture></a>
  <a href="https://hub.docker.com/r/authelia/base/tags"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fdocker%2Fimage-size%2Fauthelia%2Fbase%2Flatest.json&query=%24.message&label=image%20size&logo=docker&logoColor=%232496ed&mode=dark&size=sm&variant=outline"><img alt="Docker Size" src="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fdocker%2Fimage-size%2Fauthelia%2Fbase%2Flatest.json&query=%24.message&label=image%20size&logo=docker&logoColor=%232496ed&mode=light&size=sm&variant=outline"></picture></a>
  <a href="https://hub.docker.com/r/authelia/base"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fdocker%2Fpulls%2Fauthelia%2Fbase.json&query=%24.message&label=pulls&logo=docker&logoColor=%232496ed&mode=dark&size=sm&variant=outline"><img alt="Docker Pulls" src="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fdocker%2Fpulls%2Fauthelia%2Fbase.json&query=%24.message&label=pulls&logo=docker&logoColor=%232496ed&mode=light&size=sm&variant=outline"></picture></a>
</p>

<p align="center">
  <a href="https://discord.authelia.com"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/discord/707844280412012608.svg?logo=discord&logoColor=%235865f2&mode=dark&size=sm&variant=outline"><img alt="Discord" src="https://shieldcn.dev/discord/707844280412012608.svg?logo=discord&logoColor=%235865f2&mode=light&size=sm&variant=outline"></picture></a>
  <a href="https://matrix.to/#/#support:authelia.com"><picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fmatrix%2Fauthelia-support%3Amatrix.org.json&query=%24.message&label=matrix&logo=matrix&mode=dark&size=sm&variant=outline"><img alt="Matrix" src="https://shieldcn.dev/badge/dynamic/json.svg?url=https%3A%2F%2Fimg.shields.io%2Fmatrix%2Fauthelia-support%3Amatrix.org.json&query=%24.message&label=matrix&logo=matrix&mode=light&size=sm&variant=outline"></picture></a>
</p>

# authelia/base

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
- **30/09/2026:** Update busybox to v1.38.0-3ubuntu3 and chisel to v1.5.1
- **07/09/2026:** Update busybox to v1.38.0-3ubuntu1 and chisel to v1.5.0
- **12/07/2026:** Update chisel to v1.4.2
- **08/04/2026:** Update chisel to v1.4.1
- **06/03/2026:** Update chisel to v1.4.0 and su-exec to v0.3
- **02/10/2025:** Cross-compile BusyBox in authelia/crossbuild
- **28/10/2024:** Swap to musl-static variant of su-exec for multi-arch support
- **16/10/2024:** Add Provenance and SBOM attestations
- **15/10/2024:** Initial release
