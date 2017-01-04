#! /bin/bash

# Defining global parameters of this script.
VIMRC_URL="https://gist.githubusercontent.com/matsKNY/\
696bb092e52ff61925e1136baaa2cdc6/raw/\
e1dc4f97ce6f9e8bb9057e6e70b0af8a73744a99/.vimrc_minimal"
MOLOKAI_URL="https://raw.githubusercontent.com/tomasr/\
molokai/master/colors/molokai.vim"

# Installing vim-enhanced after updating the installed software.
echo "Installing Vim-Enhanced ..."
yum -y update
yum -y install vim-enhanced
yum -y install wget

# Getting the .vimrc file.
echo "Getting the .vimrc file ..."
wget -O .vimrc "$VIMRC_URL"

# Creating the path the colorschemes directory, if necessary.
mkdir -p "/root/.vim/colors"

# Getting the Molokai theme and moving it to the colorschemes
# directory.
echo "Getting the Molokai theme ..."
wget -O molokai.vim "$MOLOKAI_URL"
mv molokai.vim /root/.vim/colors/
