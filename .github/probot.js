// PR commentary for Authelia branch based contributions
on('pull_request.opened')
    .filter(
        context =>
            context.payload.pull_request.head.label.slice(0, 10) === 'baseimage:'
    )
    .filter(
        context =>
            context.payload.pull_request.head.ref.slice(0, 17) !== 'all-contributors/'
    )
    .filter(
        context =>
            context.payload.pull_request.head.ref.slice(0, 11) !== 'dependabot/'
    )
    .filter(
        context =>
            context.payload.pull_request.head.ref.slice(0, 9) !== 'renovate/'
    )
    .comment(`## Artifacts
These changes are published for testing on DockerHub and GitHub Container Registry.

### Docker Container
* \`docker pull authelia/base:{{ pull_request.head.ref }}\`
* \`docker pull ghcr.io/authelia/base:{{ pull_request.head.ref }}\``)

// PR commentary for third party based contributions
on('pull_request.opened')
    .filter(
        context =>
            context.payload.pull_request.head.label.slice(0, 10) !== 'baseimage:'
    )
    .comment(`Thanks for choosing to contribute @{{ pull_request.user.login }}.

## Artifacts
These changes once approved by a team member will be published for testing on DockerHub and GitHub Container Registry.

### Docker Container
* \`docker pull authelia/base:PR{{ pull_request.number }}\`
* \`docker pull ghcr.io/authelia/base:PR{{ pull_request.number }}\``)