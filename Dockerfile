FROM fedora

ENV GO_VERSION 1.4.2

ENV PYTHON2_VERSION 2.7.9
ENV PYTHON3_VERSION 3.4.2

RUN yum install -y automake \
                   bzip2-devel \
                   cmake \
                   ctags \
                   curl \
                   docker-io \
                   expat-devel \
                   gcc \
                   gdbm-devel \
                   git \
                   libffi-devel \
                   libxml2-devel \
                   libxslt-devel \
                   libyaml-devel \
                   luajit-devel \
                   make \
                   mercurial \
                   ncurses-devel \
                   openssl-devel \
                   par \
                   python \
                   python-pip \
                   readline-devel \
                   sqlite-devel \
                   sudo \
                   tar \
                   the_silver_searcher \
                   tmux \
                   tree \
                   wget \
                   zlib-devel \
                   zsh

# Install go
RUN curl -s https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -zx

# Install Vim from source
RUN cd /tmp \
       && hg clone https://vim.googlecode.com/hg/ vim \
       && cd vim \
       && ./configure --with-features=huge --prefix /usr/local --with-tlib=ncurses --enable-pythoninterp --enable-multibyte --enable-luainterp --with-luajit --disable-tclinterp --disable-netbeans --with-compiledby='Ross Timson <ross@rosstimson.com>' \
       && make \
       && make install \
       && rm -rf /tmp/vim

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
RUN mkdir -p /home/rosstimson/.vim/bundle \
    && git clone --depth 1 https://github.com/Shougo/neobundle.vim.git /home/rosstimson/.vim/bundle/neobundle.vim
RUN touch /home/rosstimson/.z

# Golang setup
RUN mkdir -p /home/rosstimson/go
ENV GOROOT /usr/local/go
ENV GOPATH /home/rosstimson/go
ENV PATH /home/rosstimson/go/bin:/usr/local/go/bin:$PATH
RUN go get github.com/tools/godep \
    && go get github.com/golang/lint/golint \
    && go get golang.org/x/tools/cmd/goimports \
    && go get github.com/jstemmer/gotags

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

# Must be run as my user.
RUN /home/rosstimson/.vim/bundle/neobundle.vim/bin/neoinstall
CMD ["/bin/zsh"]
