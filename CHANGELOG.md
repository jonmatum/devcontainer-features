# Changelog

## [1.2.0](https://github.com/jonmatum/devcontainer-features/compare/v1.1.3...v1.2.0) (2025-04-30)


### Features

* unified shell + sandbox setup with Copier, devcontainer CLI, and robust features ([#43](https://github.com/jonmatum/devcontainer-features/issues/43)) ([4efb20c](https://github.com/jonmatum/devcontainer-features/commit/4efb20ccf7244eedcbde25f576e1ad150292a2e7))

## [1.1.3](https://github.com/jonmatum/devcontainer-features/compare/v1.1.2...v1.1.3) (2025-04-28)


### Bug Fixes

* **shell:** update feature option parameters to use uppercase environment variables ([2f99951](https://github.com/jonmatum/devcontainer-features/commit/2f99951f05b8e5a8674447ca4d738e38af2ba752))

## [1.1.2](https://github.com/jonmatum/devcontainer-features/compare/v1.1.1...v1.1.2) (2025-04-28)


### Bug Fixes

* **shell:** ensure always disable the Powerlevel10k wizard ([1ec6969](https://github.com/jonmatum/devcontainer-features/commit/1ec69697a9e0ad3b4c255cc5ea81175a8bbd4d27))

## [1.1.1](https://github.com/jonmatum/devcontainer-features/compare/v1.1.0...v1.1.1) (2025-04-28)


### Bug Fixes

* **shell:** ensure opinionated config files are applied before fixing permissions ([90b2b01](https://github.com/jonmatum/devcontainer-features/commit/90b2b01bfdda6fff43d2bea3925d596ff965e988))

## [1.1.0](https://github.com/jonmatum/devcontainer-features/compare/v1.0.1...v1.1.0) (2025-04-28)


### Features

* **shell:** add support for optional post-install script via URL ([#37](https://github.com/jonmatum/devcontainer-features/issues/37)) ([f029b13](https://github.com/jonmatum/devcontainer-features/commit/f029b13735b9578b344b529a3ae29052438ae688))

## [1.0.1](https://github.com/jonmatum/devcontainer-features/compare/v1.0.0...v1.0.1) (2025-04-28)


### Bug Fixes

* **tests:** remove invalid color_and_hello scenario to match current feature set ([#35](https://github.com/jonmatum/devcontainer-features/issues/35)) ([4e23b91](https://github.com/jonmatum/devcontainer-features/commit/4e23b91f756a6c2686d4c4d2e1f3220ae66a7540))

## 1.0.0 (2025-04-28)


### Features

* add workflow to test features in isolated containers ([#19](https://github.com/jonmatum/devcontainer-features/issues/19)) ([9abaeb5](https://github.com/jonmatum/devcontainer-features/commit/9abaeb5beb20ca54965aa41fa4553ab0b2900ec3))
* **ci:** add complete validate, release, publish workflows with local act config ([#4](https://github.com/jonmatum/devcontainer-features/issues/4)) ([6696146](https://github.com/jonmatum/devcontainer-features/commit/6696146ba58fa39f4bfe187c36243c49700b9bd4))
* **ci:** setup validate, release, and publish workflows for DevContainer features ([#3](https://github.com/jonmatum/devcontainer-features/issues/3)) ([c81feac](https://github.com/jonmatum/devcontainer-features/commit/c81feac96e65b7bd816539be03508752628cbb31))
* **publish:** implement feature artifact packaging and release upload ([#12](https://github.com/jonmatum/devcontainer-features/issues/12)) ([0eb0684](https://github.com/jonmatum/devcontainer-features/commit/0eb06843e556327f2767cf8e16be07121fe6ef9c))
* **publish:** implement feature artifact packaging and release upload ([#13](https://github.com/jonmatum/devcontainer-features/issues/13)) ([ff3821b](https://github.com/jonmatum/devcontainer-features/commit/ff3821b66c0cb4ffb2e041cbe2a100fa7c71c57d))
* **release:** configure clean release-please workflow ([#32](https://github.com/jonmatum/devcontainer-features/issues/32)) ([5555785](https://github.com/jonmatum/devcontainer-features/commit/5555785d7861d54c90f3a13e67067a8e0a58f281))
* **shell:** add initial shell environment feature (zsh, oh-my-zsh, powerlevel10k) ([#2](https://github.com/jonmatum/devcontainer-features/issues/2)) ([9011739](https://github.com/jonmatum/devcontainer-features/commit/9011739e40609e488d415ddbe5d72219e6002696))
* **shell:** add new feature and tests for default and minimal scenarios ([#22](https://github.com/jonmatum/devcontainer-features/issues/22)) ([b6bb18f](https://github.com/jonmatum/devcontainer-features/commit/b6bb18f8bec8bf46e1a950182eb9671196330f52))
* **shell:** add robust shell feature supporting Zsh and optional Oh My Zsh setup ([b6bb18f](https://github.com/jonmatum/devcontainer-features/commit/b6bb18f8bec8bf46e1a950182eb9671196330f52))
* **shell:** initial release setup and versioning test ([#26](https://github.com/jonmatum/devcontainer-features/issues/26)) ([e40dc58](https://github.com/jonmatum/devcontainer-features/commit/e40dc580ef643f1f2a467fd4eb571e6dbaf96de9))
* **shell:** prepare release test with improved shell setup metadata ([#24](https://github.com/jonmatum/devcontainer-features/issues/24)) ([d0d2777](https://github.com/jonmatum/devcontainer-features/commit/d0d27771aaa15aaf6d1f9482ffee69c489d74276))


### Bug Fixes

* **ci:** pass GITHUB_TOKEN for release-please to enable labels and PRs ([#9](https://github.com/jonmatum/devcontainer-features/issues/9)) ([c666226](https://github.com/jonmatum/devcontainer-features/commit/c6662261b4cac38d54855b01a189c3f3f7de81cb))
* configure release-please to support multi-package managed releases ([#5](https://github.com/jonmatum/devcontainer-features/issues/5)) ([5a4484c](https://github.com/jonmatum/devcontainer-features/commit/5a4484c6591c25efdd2d702a5fb342795d9a4092))
* **release-please:** update configuration ([#10](https://github.com/jonmatum/devcontainer-features/issues/10)) ([c4f1212](https://github.com/jonmatum/devcontainer-features/commit/c4f12127eda959cb65dda415d34dda79b6445379))
* **release:** enable auto-publishing GitHub Releases ([#16](https://github.com/jonmatum/devcontainer-features/issues/16)) ([7852d0d](https://github.com/jonmatum/devcontainer-features/commit/7852d0da0c71a7f68ff74c9ca0c21573381b6517))
* **release:** enable auto-publishing GitHub Releases ([#17](https://github.com/jonmatum/devcontainer-features/issues/17)) ([f9a6a56](https://github.com/jonmatum/devcontainer-features/commit/f9a6a566cdf5279cb3c5797ecd43fd9359e9bceb))
* trigger new release ([#14](https://github.com/jonmatum/devcontainer-features/issues/14)) ([f6b3a44](https://github.com/jonmatum/devcontainer-features/commit/f6b3a4409b622533504c869fdd6d6b03544fe364))
* **workflow:** correct release-please config filename in workflow ([#6](https://github.com/jonmatum/devcontainer-features/issues/6)) ([80a3169](https://github.com/jonmatum/devcontainer-features/commit/80a3169adc983162cf550e98d675ec04da6843cb))
