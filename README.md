# 🦕 nanosaur-runner

[![Discord](https://img.shields.io/discord/797461428646707211)](https://discord.gg/YvxjxEFPkb) [![GitHub Org's stars](https://img.shields.io/github/stars/rnanosaur?style=social)](https://github.com/rnanosaur) [![Twitter Follow](https://img.shields.io/twitter/follow/raffaello86?style=social)](https://twitter.com/raffaello86) [![robo.panther](https://img.shields.io/badge/Follow:-robo.panther-E4405F?style=social&logo=instagram)](https://www.instagram.com/robo.panther/)

**nanosaur** The smallest [NVIDIA Jetson](https://developer.nvidia.com/buy-jetson) dinosaur robot, **open-source**, fully **3D printable**, based on [**ROS2**](https://www.ros.org/) & [**Isaac ROS**](https://developer.nvidia.com/isaac-ros-gems).

<small>Designed & made by [Raffaello Bonghi](https://rnext.it)</small>

[![nanosaur](https://nanosaur.ai/assets/images/banner.jpg)](https://nanosaur.ai)

Meet nanosaur:
* 🦕 Website: [nanosaur.ai](https://nanosaur.ai)
* 🦄 Do you need an help? [Discord](https://discord.gg/YvxjxEFPkb)
* 🧰 For technical details follow [wiki](https://github.com/rnanosaur/nanosaur/wiki)
* 🐳 nanosaur [Docker hub](https://hub.docker.com/u/nanosaur)
* ⁉️ Something wrong? Open an [issue](https://github.com/rnanosaur/nanosaur/issues)

-------------

Nanosaur github **self hosted runner** based from [Docker Github Actions Runner](https://github.com/myoung34/docker-github-actions-runner)

# Before install

You need a [Github token PAT](https://developer.github.com/v3/actions/self_hosted_runners/#create-a-registration-token)

the following scopes are selected:

* repo (all)
* workflow
* admin:org (all) (**mandatory for organization-wide runner**)
* admin:public_key - read:public_key
* admin:repo_hook - read:repo_hook
* admin:org_hook
* notifications

# Install

Install the nanosaur runner

```
git clone https://github.com/rnanosaur/nanosaur-runner.git
cd nanosaur-runner && ./install.sh
```

# Run self-hosed runner

## NVIDIA Jetson

```
docker-compose up -d
```

## x86-64 architecture

```
docker compose -f docker-compose.x86.yml up -d
```