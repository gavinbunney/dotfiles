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
    echo "> Install mkdocs and themes"
    pip3 install mkdocs
    pip3 install mkdocs-gitbook
}

function gitconfig() {
    echo ">"
    echo "> Setting up gitconfig"
    git config --global alias.lg 'log --graph --abbrev-commit --decorate --date=relative'
    git config --global alias.lgs 'log --graph --oneline --decorate --date=relative --all'
    git config --global alias.amend 'commit --amend --no-edit'

    git config --global --replace-all user.name 'Gavin Bunney'
    git config --global --replace-all user.email '409207+gavinbunney@users.noreply.github.com'

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
profile

echo ">"
echo "> Done!"
