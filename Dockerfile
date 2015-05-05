FROM fedora

ENV GO_VERSION 1.4.2

ENV PYTHON2_VERSION 2.7.9
ENV PYTHON3_VERSION 3.4.3

RUN yum install -y autoconf \
                   automake \
                   bzip2-devel \
                   cmake \
                   ctags \
                   curl \
                   docker-io \
                   expat-devel \
                   gcc \
                   gcc-c++ \
                   gdbm-devel \
                   git \
                   libffi-devel \
                   libtool \
                   libxml2-devel \
                   libxslt-devel \
                   libyaml-devel \
                   make \
                   mercurial \
                   ncurses-devel \
                   openssl-devel \
                   par \
                   patch \
                   pkgconfig \
                   python \
                   python-pip \
                   readline-devel \
                   sqlite-devel \
                   sudo \
                   tar \
                   the_silver_searcher \
                   tmux \
                   tree \
                   unzip \
                   vim \
                   wget \
                   zlib-devel \
                   zsh

# Install go
RUN curl -s https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -zx

# Install Neovim from source
RUN cd /tmp \
       && git clone --depth 1 https://github.com/neovim/neovim.git \
       && cd neovim \
       && echo "" > cmake/GenerateHelptags.cmake \
       && make \
       && make install \
       && rm -rf /tmp/neovim

# Create my user
RUN useradd rosstimson --uid 1000 --shell /bin/zsh

# Setup sudo, needed for using Docker when docker.sock has been bind mounted.
RUN echo 'rosstimson	ALL=(ALL)	NOPASSWD: ALL' >> /etc/sudoers.d/rosstimson

# Setup camp
ADD dotfiles/zsh /home/rosstimson/.zsh
ADD dotfiles/zshrc /home/rosstimson/.zshrc
ADD dotfiles/tmux.conf /home/rosstimson/.tmux.conf
ADD dotfiles/gitconfig /home/rosstimson/.gitconfig
ADD dotfiles/gitignore /home/rosstimson/.gitignore
ADD dotfiles/vimrc /home/rosstimson/.vimrc
RUN ln -s /home/rosstimson/.vimrc /home/rosstimson/.nvimrc
RUN ln -s /home/rosstimson/.vim /home/rosstimson/.nvim
RUN touch /home/rosstimson/.z
RUN git clone --depth 1 https://github.com/chriskempson/base16-shell.git /home/rosstimson/.base16-shell

# Golang setup
RUN mkdir -p /home/rosstimson/go
ENV GOROOT /usr/local/go
ENV GOPATH /home/rosstimson/go
ENV PATH /home/rosstimson/go/bin:/usr/local/go/bin:$PATH
RUN go get github.com/tools/godep \
    && go get github.com/golang/lint/golint \
    && go get golang.org/x/tools/cmd/goimports \
    && go get github.com/jstemmer/gotags \
    && go get github.com/nsf/gocode

# Ensure ownership of $HOME is correct.
RUN chown -R rosstimson: /home/rosstimson

# Cleanup
RUN yum clean all && rm -rf /tmp/*

WORKDIR /home/rosstimson
USER rosstimson

# Python setup
RUN curl -sL https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
# RUN git clone https://github.com/yyuu/pyenv-virtualenv.git /home/rosstimson/.pyenv/plugins/pyenv-virtualenv
ENV PYENV_ROOT /home/rosstimson/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init -)" \
    && pyenv install $PYTHON2_VERSION \
    && pyenv install $PYTHON3_VERSION \
    && pyenv shell $PYTHON2_VERSION \
    && pip install virtualenv jedi \
    && pyenv shell $PYTHON3_VERSION \
    && pip install jedi
# Set default Python version
ENV PYENV_VERSION $PYTHON3_VERSION

# Must be run as my user to fix weird permissions issue and to read .vimrc
RUN curl -fLo /home/rosstimson/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN vim +PlugInstall +qall

CMD ["/bin/zsh"]
