# home_ops

My attempt to automate personal infrastructure using nix

```shell
bash install.sh
```


```shell
cd "${HOME}/repos/github.com/aaqaishtyaq/home_ops"

# nix package manager and home-manager
nix build --experimental-features 'nix-command flakes' '.#linux-server'

# nixos and home-manager
sudo nixos-rebuild switch --flake '.#pix'
```

Note: This is highly experimental

To unlock secrets file...
```
$ git-crypt unlock
```
---

Go to [Dotfiles Repo](https://github.com/aaqaishtyaq/dotfiles) for `stable` configurations.
