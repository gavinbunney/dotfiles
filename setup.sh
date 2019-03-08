#!/bin/bash

set -e

DOTFILES_DIR=~/.dotfiles

function homebrew() {
    echo ">"
    echo "> Installing Brewfile"
    brew bundle
}

function okta_aws() {
    if [[ -d "$HOME/.okta" ]]; then
        return 0
    fi

    echo ">"
    echo "> Installing Okta AWS"
    PREFIX=~/.okta bash <(curl -fsSL https://raw.githubusercontent.com/oktadeveloper/okta-aws-cli-assume-role/master/bin/install.sh) -i
}

function gitconfig() {
    echo ">"
    echo "> Setting up gitconfig"
    git config --global alias.lg 'log --graph --abbrev-commit --decorate --date=relative'
    git config --global alias.lgs 'log --graph --oneline --decorate --date=relative --all'
    git config --global alias.amend 'commit --amend --no-edit'

    git config --global --replace-all user.name 'Gavin Bunney'
    git config --global --replace-all user.email 'gbunney@guidewire.com'

    git config --global pull.rebase true
    git config --global push.default simple
    git config --global --replace-all core.excludesfile '/Users/gbunney/.gitignore_global'
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
okta_aws
gitconfig
profile

echo ">"
echo "> Done!"
