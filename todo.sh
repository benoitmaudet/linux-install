#Set fish as default shell
chsh /usr/bin/fish

#Install notification manager
sudo apt-get remove -y --purge dunst
sudo apt-get install -y notify-osd

#Install video/audio
sudo apt-get install -y vlc pulseaudio alsa-base alsa-oss
sudo usradd `whoami` audio

sudo apt-get install -y curl gedit git-core htop strings libreoffice 

#Install network
sudo apt-get install -y network-manager-gnome bcmwl-kernel-source


#Install lightdm and gtk greeter
sudo apt-get install -y lightdm lightdm-gtk-greeter

sudo bash -c 'echo "background=/home/benoit/wallpapers/autumn_bench-HD.jpg" >> /etc/lightdm/lightdm-gtk-greeter.conf'
sudo bash -c 'echo "font-name=menlo" >> /etc/lightdm/lightdm-gtk-greeter.conf'

sudo bash -c 'echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/50-no-guest.conf'
sudo bash -c 'echo "allow-guest=false" >> /etc/lightdm/lightdm.conf.d/50-no-guest.conf'

#Set random wallpaper
bash -c 'crontab -l | { cat; echo "* * * * * feh --bg-scale --randomize /home/benoit/wallpapers/*"; } | crontab -'

#For redshift in Paris
redshift  -m randr -b 0.8 -l 48.8:2.3 -v

#Config sudo
#Metasploit + postgres
#hostname ?
#folder rights
#firefox profile







