# Content

This directory contains stuff used on the GitLab CI.

## docker

Contains definitions for Docker images.

## testbed

Contains definitions for testbed related tests.

## scripts

Contains scripts used on GitLab CI.

## tests

Contains tests used on GitLab CI.

## build.yml

Contains definition of the GitLab CI build test job templates used during `build` stage. Those templates can then be extended by other GitLab CI jobs in order to keep things DRY.

### .build test config

Allows build testing of specific configurations defined in the profiles directory, using `scripts/gen_config.py` under the hood.

Example usage:

```yaml
include:
 - local: .gitlab/build.yml

stages:
 - build

build test netgear-rax40 prpl webui:
  extends: .build test config
```

Which is going to build test prplwrt with `netgear-rax40`, `prpl` and `webui` profiles.

## docker.yml

Provides support for building, tagging and pushing the Docker images to image registry.

For example let's build image `foo`.

Prerequisites:

 * Create directory for new Docker image `mkdir -p .gitlab/docker/foo`
 * Docker image description `$EDITOR .gitlab/docker/foo/Dockefile`

Then just put following into `.gitlab/docker/foo/gitlab.yml`

```yaml
build Docker image foo:
  extends: .build Docker image
```

## testbed.yml

Provides bits needed for runtime testing on real device using [labgrid](https://labgrid.readthedocs.io/en/latest/) Python testing framework.

Supported devices:

 * Netgear RAX40
