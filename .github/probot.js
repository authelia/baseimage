const excludedBranchPrefixes =
    /^(docs|all-contributors\/|dependabot\/|renovate\/)/;

// PR commentary for Authelia branch based contributions
on("pull_request.opened")
    .filter((context) =>
        context.payload.pull_request.head.label.startsWith("authelia:"),
    )
    .filter((context) => {
        return !excludedBranchPrefixes.test(context.payload.pull_request.head.ref);
    })
    .filter((context) => !context.payload.pull_request.title.startsWith("docs"))
    .comment(`## Artifacts
These changes are published for testing on Buildkite, DockerHub and GitHub Container Registry.

### Docker Container
* \`docker pull authelia/base:{{ pull_request.head.ref }}\`
* \`docker pull ghcr.io/authelia/base:{{ pull_request.head.ref }}\``);

// PR commentary for third party based contributions
on("pull_request.opened").filter((context) =>
    !context.payload.pull_request.head.label.startsWith("authelia:"),
)
    .comment(`## Artifacts
These changes once approved by a team member will be published for testing on Buildkite, DockerHub and GitHub Container Registry.

### Docker Container
* \`docker pull authelia/base:PR{{ pull_request.number }}\`
* \`docker pull ghcr.io/authelia/base:PR{{ pull_request.number }}\``);
