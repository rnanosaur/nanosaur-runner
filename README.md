# 🦕 nanosaur-jetson-runner

Nanosaur github actions server runner based from [Docker Github Actions Runner](https://github.com/myoung34/docker-github-actions-runner)

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

Follow the installer running

```
git clone https://github.com/rnanosaur/nanosaur-jetson-runner.git
cd nanosaur-jetson-runner && ./install.sh
```

# Reference

Meet nanosaur:
* 🦕 Website: [nanosaur.ai](https://nanosaur.ai)
* 🦄 Do you need an help? [Discord](https://discord.gg/YvxjxEFPkb)
* 🧰 For technical details follow [wiki](https://github.com/rnanosaur/nanosaur/wiki)
* 🐳 Nanosaur [Docker hub](https://hub.docker.com/u/nanosaur)
* ⁉️ Something wrong? Open an [issue](https://github.com/rnanosaur/nanosaur/issues)