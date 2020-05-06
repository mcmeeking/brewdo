# brewdo
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmcmeeking%2Fbrewdo.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmcmeeking%2Fbrewdo?ref=badge_shield)


Homebrew is an immensely useful package manager for macOS, but has always presented issues for multi-user machines and deployment via enterprise tools like Jamf Pro.

This collection of scripts (which owe their conception to [this blog post of the same name](https://www.zigg.com/code/brewdo/)) is an attempt to resolve these issues without creating any additional attack vectors, reducing the utility of `brew`, or weakening the security of clients.

## Overview

The [`install-brew.sh`](install-brew.sh) script performs the following actions:

1. Install Xcode command-line tools if they are not present
2. Create the hidden **standard** user, "_brew", which will become the executing user for all `brew` calls
3. Add flags to `visudo` to allow passwordless `sudo` for this user (*will only apply when the user is an admin*)
4. Install the latest version of Homebrew
5. Install an executable `brewdo` in `/usr/local/bin` - This becomes the "`sudo`-ised" `brew` command which the additional scripts use to install and manage packages
6. Installs `md5sha1sum` for automatic checksum verification of formulae/casks, and `python3` which is optional but recommended

Once installed, `brew` can be invoked using the following sequence as root:

```bash
# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

brewdo # Whatever arguments you'd normally give brew

# Relegate back to standard user
dscl /Local/Default -delete /groups/admin GroupMembership "_brew"
```

It can also be called locally by any system admin using `sudo brewdo ...`

Arguments passed to `brewdo` are passed 1:1 to `brewdo`, so `sudo brewdo cask install google-chrome` on a machine `brewdo` is installed on is equivalent to `brew cask install google-chrome` on a personal machine which only has `brew`.

## Terminology

For anyone unfamiliar with Homebrew, there is a [description of terminology in their docs](https://github.com/Homebrew/brew/blob/master/docs/Formula-Cookbook.md). The generalised TL;DR version is:

| Term | Meaning |
|---|---|
| cask | Installs native macOS apps |
| formulae | Installs command-line utilities |

## Usage

Example scripts are included for deploying and uninstalling apps and command-line utilities via Jamf Pro using `$4` as the token. Tokens can be found by using `sudo brewdo search` followed by the app or package you're looking for.

## Extension Attribute

The extension attribute included in this repo presents the number of cask updates available, and can be used in conjuction with the [`install-updates.sh`](install-updates.sh) script to patch all Homebrew-installed apps on the machine via policy.

## Credits

Original credit for the install script goes to Richard Purves (<richard@richard-purves.com>)

Original credit for the "brewdo" name, and sandoxing process goes to Mattie Behrens ([@zigg](https://github.com/zigg))


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmcmeeking%2Fbrewdo.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmcmeeking%2Fbrewdo?ref=badge_large)