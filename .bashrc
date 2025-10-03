#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source .profile if it exists (for environment variables)
if [ -f ~/.profile ]; then
    source ~/.profile
fi

