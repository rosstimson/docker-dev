My Dockerized Dev Environment
=============================

Includes
--------

* Fedora base
* Go
* Python (latest 2 and 3 via pyenv)
* Neovim (from src)
* fzf
* Tmux
* Zsh
* + dotfiles

Usage
-----

The main `CMD` is `/bin/zsh` so just: `docker run -it rosstimson/dev`

I mount local volumes with the following shell aliases:

```shell
function ddev-go () {
  docker run -it --name $1 \
    -h go-dev \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v `pwd`:/home/rosstimson/go/src/github.com/rosstimson/$1 \
    rosstimson/dev
}

function ddev-py () {
  docker run -it --name $1 \
  -h py-dev \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v `pwd`:/home/rosstimson/python/$1 \
  rosstimson/dev
}
```

I can then run `ddev-go my-go-project` and get the current local
directory mounted appropriately along with the Docker socket being
mounted too.

__Note: You'll need to use `sudo` if running `docker` commands within
the container.__

License and Author
------------------

Author:: [Ross Timson][rosstimson]
<[ross@rosstimson.com](mailto:ross@rosstimson.com)>.

License:: Licensed under [WTFPL][wtfpl].


[rosstimson]:         https://rosstimson.com
[repo]:               https://github.com/rosstimson/docker-dev
[issues]:             https://github.com/rosstimson/docker-dev/issues
[wtfpl]:              http://www.wtfpl.net/
