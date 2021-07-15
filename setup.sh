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

function terraform() {
    echo ">"
    echo "> Installing terraform versions"
    mkdir -p ~/.terraform.d/plugin-cache
    tfenv install 1.0.0
    tfenv install 0.15.3
    tfenv install 0.13.4
    tfenv install 0.12.29
    tfenv install 0.11.11
    tfenv use 1.0.0
}

function gitconfig() {
    echo ">"
    echo "> Setting up gitconfig"
    git config --global alias.lg 'log --graph --abbrev-commit --decorate --date=relative'
    git config --global alias.lgs 'log --graph --oneline --decorate --date=relative --all'
    git config --global alias.amend 'commit --amend --no-edit'

    git config --global --replace-all user.name 'Gavin Bunney'
    git config --global --replace-all user.email '409207+gavinbunney@users.noreply.github.com'
    git config --global commit.gpgsign false

    git config --global pull.rebase true
    git config --global rebase.autoStash true
    git config --global push.default simple
    git config --global --replace-all core.excludesfile '/Users/gbunney/.gitignore_global'

    git config --global commit.message "${DOTFILES_DIR}/.gitmessage"
}

function max_files() {
    echo ">"
    echo "> Enabling higher max file/proc limits"
    cat <<EOF | sudo tee /Library/LaunchDaemons/limit.maxfiles.plist > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>524288</string>
      <string>524288</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>
EOF
    cat <<EOF | sudo tee /Library/LaunchDaemons/limit.maxproc.plist > /dev/null

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple/DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
      <key>Label</key>
      <string>limit.maxproc</string>
      <key>ProgramArguments</key>
      <array>
          <string>launchctl</string>
          <string>limit</string>
          <string>maxproc</string>
          <string>2048</string>
          <string>2048</string>
      </array>
      <key>RunAtLoad</key>
      <true />
      <key>ServiceIPC</key>
      <false />
  </dict>
</plist>
EOF

    sudo chmod 644 /Library/LaunchDaemons/limit.maxfiles.plist
    sudo chmod 644 /Library/LaunchDaemons/limit.maxproc.plist
    sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
    sudo chown root:wheel /Library/LaunchDaemons/limit.maxproc.plist
    sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist
    sudo launchctl load -w /Library/LaunchDaemons/limit.maxproc.plist
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
terraform
max_files
profile

echo ">"
echo "> Done!"

