FROM fedora

ENV GO_VERSION 1.4.1

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
RUN mkdir /home/rosstimson/.z

# Golang setup
RUN mkdir -p /home/rosstimson/go
ENV GOROOT /usr/local/go
ENV GOPATH /home/rosstimson/go
ENV PATH /home/rosstimson/go/bin:/usr/local/go/bin:$PATH
RUN go get github.com/tools/godep
RUN go get github.com/golang/lint/golint
RUN go get golang.org/x/tools/cmd/goimports
RUN go get github.com/jstemmer/gotags

# Python setup
RUN pip install jedi

# Ensure ownership of $HOME is correct.
RUN chown -R rosstimson: /home/rosstimson

# Cleanup
RUN yum clean all && rm -rf /tmp/*

WORKDIR /home/rosstimson
USER rosstimson
# Must be run as my user.
RUN /home/rosstimson/.vim/bundle/neobundle.vim/bin/neoinstall
CMD ["/bin/zsh"]
