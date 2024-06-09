#!/bin/bash

# Update system and install necessary packages
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm xorg bspwm sxhkd polybar rofi alacritty dmenu feh picom

# Create configuration directories
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd
mkdir -p ~/.config/polybar

# Copy example configuration files
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/
cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/

# Make bspwmrc executable
chmod +x ~/.config/bspwm/bspwmrc

# Configure bspwmrc to launch polybar, picom, and set wallpaper
cat <<EOL > ~/.config/bspwm/bspwmrc
#!/bin/sh

# Set monitor layout
bspc monitor -d I II III IV V VI VII VIII IX X

# Start SXHKD
sxhkd &

# Start Polybar
~/.config/polybar/launch.sh &

# Start compositor
picom &

# Set wallpaper
# feh --bg-scale /path/to/your/wallpaper.jpg
EOL

# Create Polybar launch script
cat <<EOL > ~/.config/polybar/launch.sh
#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u \$UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config location ~/.config/polybar/config
polybar example &
EOL

# Make Polybar launch script executable
chmod +x ~/.config/polybar/launch.sh

# Create Polybar configuration file
cat <<EOL > ~/.config/polybar/config
[bar/example]
width = 100%
height = 30
background = #222222
foreground = #dfdfdf
fixed-center = true

modules-left = bspwm
modules-right = date

[module/bspwm]
type = internal/bspwm

[module/date]
type = internal/date
interval = 5
date = %Y-%m-%d %H:%M:%S
label = %date%
EOL

# Make BSPWM start on login
echo "exec bspwm" > ~/.xinitrc

# Prompt user to install a display manager or use startx
echo "Installation complete. You can use 'startx' to start BSPWM or install a display manager like lightdm."
echo "To install LightDM, run the following commands:"
echo "sudo pacman -S lightdm lightdm-gtk-greeter"
echo "sudo systemctl enable lightdm"

# Optionally, ask if the user wants to install and enable LightDM
read -p "Do you want to install and enable LightDM now? (y/N) " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
    echo "LightDM has been installed and enabled. Please reboot your system."
else
    echo "You chose not to install LightDM. Use 'startx' to start BSPWM."
fi
