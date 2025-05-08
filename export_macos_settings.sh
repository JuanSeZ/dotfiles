#!/bin/bash

echo "Exporting macOS settings..."

# Dock settings
echo "Dock settings:"
defaults read com.apple.dock

# Trackpad settings
echo -e "\nTrackpad settings:"
defaults read com.apple.AppleMultitouchTrackpad

# Menubar settings
echo -e "\nMenubar settings:"
defaults read NSGlobalDomain _HIHideMenuBar
defaults read NSGlobalDomain AppleMenuBarVisibleInFullscreen

# System Preferences
echo -e "\nSystem Preferences:"
defaults read NSGlobalDomain AppleShowAllExtensions
defaults read NSGlobalDomain ApplePressAndHoldEnabled
defaults read NSGlobalDomain InitialKeyRepeat
defaults read NSGlobalDomain KeyRepeat
defaults read com.apple.screensaver askForPassword
defaults read com.apple.screensaver askForPasswordDelay 