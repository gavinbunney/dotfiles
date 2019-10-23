#!/bin/bash

set -e

DOTFILES_DIR=~/.dotfiles

function homebrew() {
    echo ">"
    echo "> Installing Brewfile"
    brew bundle
}

function pip() {
    echo ">"
    echo "> Install python packages"
    pip3 install mkdocs
    pip3 install mkdocs-gitbook
    pip3 install --upgrade gimme-aws-creds
}

function nelson() {
    echo ">"
    echo "> Installing nelson"
    TMP=$(mktemp -d)
    pushd ${TMP}
    curl -L -o nelson.tar.gz https://github.com/getnelson/cli/releases/download/0.9.93/nelson-darwin-amd64-0.9.93.tar.gz
    tar -zxvf nelson.tar.gz
    chmod +x nelson
    mv nelson /usr/local/bin/
    popd ${TMP}
    rm -rf ${TMP}

    echo ">"
    echo "> Installing slipway"
    TMP=$(mktemp -d)
    pushd ${TMP}
    curl -L -o slipway.tar.gz https://github.com/getnelson/slipway/releases/download/2.0.96/slipway-darwin-amd64-2.0.96.tar.gz
    tar -zxvf slipway.tar.gz
    chmod +x slipway
    mv slipway /usr/local/bin/
    popd ${TMP}
    rm -rf ${TMP}
}

function gitconfig() {
    echo ">"
    echo "> Setting up gitconfig"
    git config --global alias.lg 'log --graph --abbrev-commit --decorate --date=relative'
    git config --global alias.lgs 'log --graph --oneline --decorate --date=relative --all'
    git config --global alias.amend 'commit --amend --no-edit'

    git config --global --replace-all user.name 'Gavin Bunney'
    git config --global --replace-all user.email '409207+gavinbunney@users.noreply.github.com'
    git config --global commit.gpgsign true

    git config --global pull.rebase true
    git config --global rebase.autoStash true
    git config --global push.default simple
    git config --global --replace-all core.excludesfile '/Users/gbunney/.gitignore_global'

    git config --global commit.message "${DOTFILES_DIR}/.gitmessage"
}

function profile() {
    echo ">"
    echo "> Creating ~/.profile"
    cat <<EOF > ~/.profile
#!/bin/bash

SHELL_ROOT=${DOTFILES_DIR}

for file in \$SHELL_ROOT/dotfiles.d/*; do
  . \$file
done
EOF
}

homebrew
pip
gitconfig
nelson
profile

echo ">"
echo "> Done!"

