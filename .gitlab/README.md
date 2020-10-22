# Content

This directory contains stuff used on the GitLab CI.

## scripts

Contains scripts used on GitLab CI.

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
