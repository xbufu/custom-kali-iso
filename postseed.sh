#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export SILENT=">/dev/null 2>&1"
# export SILENT="2>&1"

# Install VM tools
eval apt install -y open-vm-tools $SILENT
eval systemctl enable --now open-vm-tools.service $SILENT

# Install kernel headers
eval apt install -y linux-headers-$(uname -r) $SILENT

# Change shell to bash and remove zsh
eval chsh -s /bin/bash root $SILENT
eval apt remove -y zsh $SILENT

# Fix power settings
eval mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
eval wget https://raw.githubusercontent.com/Dewalt-arch/pimpmyi3-config/main/xfce4/xfce4-power-manager.xml -O /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml $SILENT

# Suppress login message
touch /root/.hushlogin

# Silence PC beep
eval mkdir -p /etc/modprobe.d
echo -e "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf $SILENT

# Fix nmap scripts
eval mkdir -p /usr/share/nmap/scripts $SILENT
rm -f /usr/share/nmap/scripts/clamav-exec.nse
eval wget https://raw.githubusercontent.com/nmap/nmap/master/scripts/clamav-exec.nse -O /usr/share/nmap/scripts/clamav-exec.nse $SILENT
eval wget https://raw.githubusercontent.com/onomastus/pentest-tools/master/fixed-http-shellshock.nse -O /usr/share/nmap/scripts/http-shellshock.nse $SILENT

# Unzip rockyou
if [ -f /usr/share/wordlists/rockyou.txt.gz ]
then
    eval gzip -dq /usr/share/wordlists/rockyou.txt.gz $SILENT
fi

# Fix minimum SMB protocol
check_min=$(cat /etc/samba/smb.conf | grep -c -i "client min protocol")
check_max=$(cat /etc/samba/smb.conf | grep -c -i "client max protocol")

if [ $check_min -ne 0 ] || [ $check_max -ne 0 ]
then
    echo -n ""
else
    sed 's/\[global\]/\[global\]\n   client min protocol = CORE\n   client max protocol = SMB3\n''/' -i /etc/samba/smb.conf
fi

# Enable SSH
eval systemctl enable --now ssh $SILENT

# Disable confirmation message when connecting to new hosts over SSH
if [ -f /etc/ssh/ssh_config ]
then
    echo "StrictHostKeyChecking=no" >> /etc/ssh/ssh_config
fi

# Allow root to login with password
if [ -f /etc/ssh/sshd_config ]
then
    sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
fi

# Install pip2
check_pip=$(whereis pip | grep -i -c "/usr/local/bin/pip2.7")
if [ $check_pip -ne 1 ]
then
    eval curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py $SILENT
    eval python2 /tmp/get-pip.py $SILENT
    rm -f /tmp/get-pip.py
    eval pip --no-python-version-warning install setuptools $SILENT

    if [ ! -f /usr/bin/pip3 ]
    then
        eval apt reinstall -y python3-pip $SILENT
    fi
fi

# Fix Python3 path
echo -e '\n# Python' >> /root/.bashrc
echo -e 'export PATH=$PATH:$HOME/.local/bin' >> /root/.bashrc

# Install pipx
eval apt install -y pipx $SILENT
eval "$(register-python-argcomplete pipx)" $SILENT
echo -e '\n# pipx' >> /root/.bashrc
echo -e 'eval "$(register-python-argcomplete pipx)"\n' >> /root/.bashrc

# Fix Java path
echo -e "\n# Java" >> /root/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.bashrc
echo -e 'export PATH=$PATH:$JAVA_HOME/bin' >> /root/.bashrc

# Install go
eval apt install -y golang $SILENT

if [ ! -d /root/go ]
then
    mkdir -p /root/go/{bin,src}
fi

echo -e "\n# golang" >> /root/.bashrc
echo 'export GOPATH=$HOME/go' >> /root/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> /root/.bashrc

# Fix impacket
arr=('addcomputer.py' 'atexec.py' 'dcomexec.py' 'dpapi.py' 'esentutl.py' 'findDelegation.py' 'GetADUsers.py' 'getArch.py' 'GetNPUsers.py'
    'getPac.py' 'getST.py' 'getTGT.py' 'GetUserSPNs.py' 'goldenPac.py' 'karmaSMB.py' 'kintercept.py' 'lookupsid.py' 'mimikatz.py'
    'mqtt_check.py' 'mssqlclient.py' 'mssqlinstance.py' 'netview.py' 'nmapAnswerMachine.py' 'ntfs-read.py' 'ntlmrelayx.py' 'ping6.py'
    'ping.py' 'psexec.py' 'raiseChild.py' 'rdp_check.py' 'registry-read.py' 'reg.py' 'rpcdump.py' 'rpcmap.py' 'sambaPipe.py' 'samrdump.py'
    'secretsdump.py' 'services.py' 'smbclient.py' 'smbexec.py' 'smbrelayx.py' 'smbserver.py' 'sniffer.py' 'sniff.py' 'split.py'
    'ticketConverter.py' 'ticketer.py' 'wmiexec.py' 'wmipersist.py' 'wmiquery.py' 'addcomputer.pyc' 'atexec.pyc' 'dcomexec.pyc' 'dpapi.pyc'
    'esentutl.pyc' 'findDelegation.pyc' 'GetADUsers.pyc' 'getArch.pyc' 'GetNPUsers.pyc' 'getPac.pyc' 'getST.pyc' 'getTGT.pyc'
    'GetUserSPNs.pyc' 'goldenPac.pyc' 'karmaSMB.pyc' 'kintercept.pyc' 'lookupsid.pyc' 'mimikatz.pyc' 'mqtt_check.pyc' 'mssqlclient.pyc'
    'mssqlinstance.pyc' 'netview.pyc' 'nmapAnswerMachine.pyc' 'ntfs-read.pyc' 'ntlmrelayx.pyc' 'ping6.pyc' 'ping.pyc' 'psexec.pyc'
    'raiseChild.pyc' 'rdp_check.pyc' 'registry-read.pyc' 'reg.pyc' 'rpcdump.pyc' 'rpcmap.pyc' 'sambaPipe.pyc' 'samrdump.pyc'
    'secretsdump.pyc' 'services.pyc' 'smbclient.pyc' 'smbexec.pyc' 'smbrelayx.pyc' 'smbserver.pyc' 'sniffer.pyc' 'sniff.pyc' 'split.pyc'
    'ticketConverter.pyc' 'ticketer.pyc' 'wmiexec.pyc' 'wmipersist.pyc' 'wmiquery.pyc' )

for impacket_file in ${arr[@]}; do
    rm -f /usr/bin/$impacket_file /usr/local/bin/$impacket_file /root/.local/bin/$impacket_file
done

eval pip uninstall impacket -y $SILENT
eval pip3 uninstall impacket -y $SILENT
fix_impacket_array
eval wget https://github.com/SecureAuthCorp/impacket/releases/download/impacket_0_10_0/impacket-0.10.0.tar.gz -O /tmp/impacket-0.10.0.tar.gz $SILENT
eval tar xfz /tmp/impacket-0.10.0.tar.gz -C /opt $SILENT
chown -R root:root /opt/impacket-0.10.0
chmod -R 755 /opt/impacket-0.10.0
eval pip3 install lsassy $SILENT
eval pip install flask $SILENT
eval pip install pyasn1 $SILENT
eval pip install pycryptodomex $SILENT
eval pip install pyOpenSSL $SILENT
eval pip install ldap3 $SILENT
eval pip install ldapdomaindump $SILENT
eval pip install wheel $SILENT
eval pip install /opt/impacket-0.10.0 $SILENT
eval pip2 install pysmb $SILENT
eval pip3 install pysmb $SILENT
rm -f /tmp/impacket-0.10.0.tar.gz
eval apt -y reinstall python3-impacket impacket-scripts $SILENT

# Enable postgresql
eval systemctl enable --now postgresql $SILENT

# Initialize msfdb
eval msdb init $SILENT

# Configure git
eval git config --global user.name "Bufu" $SILENT
eval git config --global user.email "bufu@1337.com" $SILENT
eval git config --global pull.rebase true $SILENT
eval git config --global init.defaultBranch main $SILENT

# Setup configs
eval git clone https://github.com/xbufu/dotfiles /opt/dotfiles $SILENT

# Bash aliases
eval ln -s /opt/dotfiles/bash/.bash_aliases /root/.bash_aliases $SILENT

# qTerminal
if [ -f /root/.config/qterminal.org/qterminal.ini ]
then
    eval rm -f /root/.config/qterminal.org/qterminal.ini $SILENT
else
    eval mkdir -p /root/.config/qterminal.org/ $SILENT
fi

eval ln -s /opt/dotfiles/qterminal/qterminal.ini /root/.config/qterminal.org/qterminal.ini $SILENT

# Tmux
eval ln -s /opt/dotfiles/tmux/.tmux.conf /root/.tmux.conf $SILENT
eval mkdir -p /root/.config/tmux $SILENT
eval ln -s /opt/dotfiles/tmux/ips.sh /root/.config/tmux/ips.sh $SILENT
eval ln -s /opt/dotfiles/tmux/set_box_ip.sh /usr/bin/set_box_ip $SILENT
echo -e '\n# Tmux' >> /root/.bashrc
echo "echo source /root/.bashrc > /root/.bash_profile" >> /root/.bashrc

# Set custom wallpaper
eval mkdir -p /root/Pictures $SILENT
eval wget https://github.com/xbufu/dotfiles/raw/main/mr-robot-tv-series-artwork.jpg -O /root/Pictures/wallpaper.jpg $SILENT
echo -e '\n# Wallpaper' >> /root/.bashrc
echo -e '\nxfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s /root/Pictures/wallpaper.jpg' >> /root/.bashrc $SILENT

# Setup some tools
eval mkdir -p /opt/{exploits,shells,post,enum}/{windows,linux,multi} $SILENT
eval mkdir -p /opt/powershell $SILENT

# Exploits
eval git clone https://github.com/AlmCo/Shellshocker /opt/exploits/linux/shellshocker $SILENT
eval git clone https://github.com/3ndG4me/AutoBlue-MS17-010 /opt/exploits/windows/AutoBlue-MS17-010 $SILENT
eval git clone https://github.com/helviojunior/MS17-010 /opt/exploits/windows/MS17-010 $SILENT
eval git clone https://github.com/worawit/MS17-010 /opt/exploits/windows/MS17-010-OG $SILENT
eval git clone https://github.com/andyacer/ms08_067 /opt/exploits/windows/ms08_067 $SILENT

# PowerShell
eval git clone https://github.com/samratashok/ADModule /opt/exploits/windows/ADModule $SILENT
eval git clone https://github.com/samratashok/nishang /opt/exploits/windows/nishang $SILENT
eval git clone https://github.com/PowerShellMafia/PowerSploit /opt/exploits/windows/PowerSploit $SILENT
eval git clone https://github.com/danielbohannon/Invoke-Obfuscation.git /opt/powershell/Invoke-Obfuscation $SILENT
eval git clone https://github.com/trustedsec/unicorn.git /opt/powershell/unicorn $SILENT
eval git clone https://github.com/Kevin-Robertson/Inveigh.git /opt/powershell/Inveigh $SILENT
eval git clone https://github.com/whitehat-zero/PowEnum.git /opt/powershell/PowEnum $SILENT
eval git clone https://github.com/rvrsh3ll/Misc-Powershell-Scripts.git /opt/powershell/Misc-Powershell-Scripts $SILENT
eval git clone https://github.com/dafthack/MailSniper.git /opt/powershell/MailSniper $SILENT
eval git clone https://github.com/rasta-mouse/Sherlock.git /opt/powershell/Sherlock $SILENT
eval git clone https://github.com/Kevin-Robertson/Invoke-TheHash.git /opt/powershell/Invoke-TheHash $SILENT
eval git clone https://github.com/BloodHoundAD/BloodHound.git /opt/powershell/BloodHound $SILENT
eval git clone https://github.com/xorrior/EmailRaider.git /opt/powershell/EmailRaider $SILENT
eval git clone https://github.com/ChrisTruncer/WMImplant.git /opt/powershell/WMImplant $SILENT

# Shells
eval git clone https://github.com/WhiteWinterWolf/wwwolf-php-webshell /opt/shells/multi/wwwolf-php-webshell $SILENT
eval git clone https://github.com/ivan-sincek/php-reverse-shell /opt/shells/multi/php-reverse-shell $SILENT
eval git clone https://github.com/ivan-sincek/java-reverse-tcp /opt/shells/multi/java-reverse-tcp $SILENT
eval git clone https://github.com/ivan-sincek/powershell-reverse-tcp /opt/shells/windows/powershell-reverse-tcp $SILENT

# Enum

# Post
eval git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite /opt/post/multi/privilege-escalation-awesome-scripts-suite $SILENT
eval git clone https://github.com/rebootuser/LinEnum.git /opt/post/linux/LinEnum $SILENT
eval git clone https://github.com/mzet-/linux-exploit-suggester /opt/post/linux/linux-exploit-suggester $SILENT
eval git clone https://github.com/Anon-Exploiter/SUID3NUM /opt/post/linux/SUID3NUM $SILENT
eval git clone https://github.com/saghul/lxd-alpine-builder /opt/post/linux/lxd-alpine-builder $SILENT
eval git clone https://github.com/xbufu/pe_tools /opt/post/multi/pe_tools $SILENT
eval git clone https://github.com/andrew-d/static-binaries.git /opt/post/linux/static-binaries $SILENT
mkdir -p /opt/post/linux/pspy
eval wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 -O /opt/post/linux/pspy/pspy32 $SILENT
eval wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s -O /opt/post/linux/pspy/pspy32s $SILENT
eval wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 -O /opt/post/linux/pspy/pspy64 $SILENT
eval wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s -O /opt/post/linux/pspy/pspy64s $SILENT
eval git clone https://github.com/turbo/zero2hero /opt/post/windows/zero2hero-uac-bypass $SILENT
eval git clone https://github.com/mubix/post-exploitation /opt/post/multi/post-exploitation $SILENT
