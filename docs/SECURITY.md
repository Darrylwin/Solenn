# Security policy

## Scope

Solenn has no network access, no accounts, no payments and no persistence:
release builds do not declare the `INTERNET` permission, collect nothing and
transmit nothing. Relevant reports therefore concern, for example, a build that
requests a permission it should not, leaked credentials or signing material, a
vulnerable dependency, or a weakness in the CI and release pipeline.

## Supported versions

Only the latest release is supported. A fix ships as a patch release; there are
no backport branches.

## Reporting a vulnerability

Please do not open a public issue.

- Preferred: GitHub private vulnerability reporting
  (<https://github.com/Darrylwin/Solenn/security/advisories/new>).
- Alternative: logossoudarryl20@gmail.com.

Include the affected version and build, the platform and OS version, and the
steps to reproduce.

## Response targets

- Acknowledgement within 7 days.
- Initial assessment within 30 days.

These targets are best-effort commitments from the maintainers.
