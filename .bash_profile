#!/bin/bash

# Load .profile if it exists
if [ -f ~/.profile ]; then
    source ~/.profile
fi

# Load .bashrc for interactive shells
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

