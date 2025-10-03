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

function terraform() {
    echo ">"
    echo "> Installing terraform versions"
    mkdir -p ~/.terraform.d/plugin-cache
    tfenv install 1.0.0
    # tfenv install 0.15.3
    # tfenv install 0.13.4
    # tfenv install 0.12.29
    # tfenv install 0.11.11
    tfenv use 1.0.0
}

function sdkman() {
    echo ">"
    echo "> Installing sdkman"
    
    if [ ! -d "$HOME/.sdkman" ]; then
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        echo "> SDKMAN already installed"
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi
    
    echo ">"
    echo "> Installing Java versions via SDKMAN"
    
    sdk install java 8.0.462-zulu || true
    sdk install java 17.0.16-zulu || true
    sdk install java 21.0.8-zulu || true
    sdk install java 24.0.2-zulu || true
    sdk install java 25-zulu || true
    
    sdk default java 21.0.8-zulu || true
    
    echo ">"
    echo "> Installing other useful tools via SDKMAN"
    
    sdk install maven || true
    sdk install gradle || true
    
    echo ">"
    echo "> Installed Java versions:"
    ls -la ~/.sdkman/candidates/java/ 2>/dev/null | grep "zulu" || echo "Run 'sdk list java' to see installed versions"
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

    echo ">"
    echo "> Linking bash profile files"
    ln -sf ${DOTFILES_DIR}/.bash_profile ~/.bash_profile
    ln -sf ${DOTFILES_DIR}/.bashrc ~/.bashrc
    
    echo ">"
    echo "> Linking git global ignore"
    ln -sf ${DOTFILES_DIR}/.gitignore_global ~/.gitignore_global
}

function set_bash_shell() {
    echo ">"
    echo "> Setting bash as default shell"
    
    BASH_PATH=$(which bash)
    CURRENT_SHELL=$(dscl . -read ~/ UserShell | sed 's/UserShell: //')
    
    if [ "$CURRENT_SHELL" != "$BASH_PATH" ]; then
        if ! grep -q "$BASH_PATH" /etc/shells; then
            echo "> Adding $BASH_PATH to /etc/shells"
            echo "$BASH_PATH" | sudo tee -a /etc/shells > /dev/null
        fi
        
        echo "> Changing default shell to bash"
        chsh -s "$BASH_PATH"
        echo "> Default shell changed to: $BASH_PATH"
        echo "> Please restart your terminal for changes to take effect"
    else
        echo "> Bash is already your default shell: $BASH_PATH"
    fi
}

function terminal_theme() {
    echo ">"
    echo "> Terminal Theme Setup"
    echo "> To apply Spacedust theme:"
    echo ">   1. Open Terminal > Settings (Cmd+,)"
    echo ">   2. Click the gear icon at bottom and select 'Import'"
    echo ">   3. Select: ${DOTFILES_DIR}/Spacedust.terminal"
    echo ">   4. Click 'Default' button to set Spacedust as default"
    echo "> Note: New terminal windows will use bash and the Spacedust theme"
}

homebrew
#pip
gitconfig
#terraform
sdkman
max_files
profile
set_bash_shell
terminal_theme

echo ">"
echo "> Done!"
echo "> Please restart your terminal or run: source ~/.bash_profile"

