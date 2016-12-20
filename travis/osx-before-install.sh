brew update
brew install gpg jq yarn
nvm install 7

export PATH=/usr/local/opt/gnupg/libexec/gpgbin:$PATH
export CC=clang
export CXX=clang++
