#!/bin/sh

# Install all available updates for Homebrew managed packages

# Elevate _brew to admin
dscl /Local/Default -append /groups/admin GroupMembership "_brew"

brewdo update
brewdo upgrade
brewdo cask upgrade
brewdo cleanup
brewdo cask cleanup

dscl /Local/Default -delete /groups/admin GroupMembership "_brew"