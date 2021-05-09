# home_ops

My attempt to automate personal infrastructure using nix

```shell
bash install.sh
```

```shell
cd "${HOME}/repos/github.com/aaqaishtyaq/home_ops"
nix build --experimental-features 'nix-command flakes' '.#linux-server'
```

Note: This is highly experimental

---

Go to [Dotfiles Repo](https://github.com/aaqaishtyaq/dotfiles) for `stable` configurations.
