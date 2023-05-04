# Razza's Arch Bootstrapper

This is a collection of scripts for automating and standardising my Arch Linux installations, with my preferred defaults.

It only needs the Arch ISO to get started. Once the live environment is booted up, the following can be run to start the installation:

```
curl -O https://rabs.razza.io/rabs-install.sh
chmod a+x rabs-install
./rabs-install
```

## What do you get out of the box?

This is mainly a bog standard Arch Linux installation with KDE installed. This is largely tailored to my needs, for other people, [archinstall](https://wiki.archlinux.org/title/Archinstall) exists.

* Installs important packages out of the box ([Essential](rabs/packages-stage1.txt), [Additional](rabs/packages-stage2.txt), [AUR](rabs/packages-stage2-aur.txt))
* Installs [yay](https://aur.archlinux.org/packages/yay) to allow easy install of AUR packages
* Sets up out-of-the-box disk encryption
* Uses btrfs (with the ability to easily create and restore from snapshots, in the future)
* Uses a bog standard KDE Plasma desktop

I prefer my desktop to be fairly vanilla, but also have some power under the hood. I'd normally opt for GNOME here, but there are some issues I need to sift through first.

## Future Goals

Future goals include making the ongoing maintenance easier to use, and to write further documentation about how it's set up and can be tweaked.

## Credits and Acknowledgements

* This whole thing is inspired by Luke Smith's [LARBS](https://larbs.xyz/).
* Font used in the setup script is part of <a href="https://int10h.org/oldschool-pc-fonts/" target="_blank">"The Ultimate Oldschool PC Font Pack"</a> by VileR is licenced under <a href="http://creativecommons.org/licenses/by-sa/4.0/" target="_blank">CC BY-SA</a>.
* None of this would be possible without the Arch Linux project, and the many FLOSS develops working on supporting software.
