# RoCaWeb

Test files for the installation and testing of the [RoCaWeb firewall](https://github.com/dakountche/RoCaWeb).

> These are old scripts from the Summer 2017 and really need to be reviewed because I was only discovering shell scripting at the time. I plan on doing this once we have a more stable version of RoCaWeb (update the whole thing with Hackazon and add WebGoat as well). Do not hesitate to jump in and contribute if you want to!

## `rocaweb-scripts/` Directory

This folder aims at providing the user with the necessary scripts to test RoCaWeb with Hackazon.

The main files right under **rocaweb-scripts/** are **launch.sh** and **algo\_list.txt**. **algo\_list.txt** should contain the list of the algorithms to be used by the RoCaWeb WebUI when producing the ModSecurity rules; the list of all available algorithms is available in the **README.md** file.

The **launch.sh** script is described in the **README.md** file as well.
