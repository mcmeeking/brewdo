#!/bin/sh

# Script to install Homebrew on a Mac.
# Author: richard at richard - purves dot com
# Version: 2.0 - 2019-11-17
# Updated: James McMeeking - james@jigsaw24.com

# Let's start here by caffinating the mac so it stays awake or bad things happen.
caffeinate -d -i -m -u &
caffeinatepid=$!

if [ "$(pkgutil --pkgs | grep -c com.apple.pkg.CLTools_Executables )" -lt 1 ]; then
    # Installing the Xcode command line tools on 10.7.x or higher

    osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
    cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

    # Installing the latest Xcode command line tools on 10.9.x or higher

    if [ "$osx_vers" -ge 9 ]; then

	    # Create the placeholder file which is checked by the softwareupdate tool 
    	# before allowing the installation of the Xcode command line tools.
	
	    touch "$cmd_line_tools_temp_file"
	
	    # Identify the correct update in the Software Update feed with "Command Line Tools" in the name for the OS version in question.
	
	    if [ "$osx_vers" -gt 9 ]; then
            cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "$osx_vers" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	    elif [ "$osx_vers" -eq 9 ]; then
	        cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "Mavericks" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	    fi
	
	    # Check to see if the softwareupdate tool has returned more than one Xcode
	    # command line tool installation option. If it has, use the last one listed
	    # as that should be the latest Xcode command line tool installer.
	
	    if (( $(grep -c . <<< "$cmd_line_tools") > 1 )); then
	        cmd_line_tools_output="$cmd_line_tools"
	        cmd_line_tools=$(printf %s "$cmd_line_tools_output" | tail -1)
	    fi
	
	    # Install the command line tools
	
	    softwareupdate -i "$cmd_line_tools" --verbose
	
	    # Remove the temp file
	
	    if [ -f "$cmd_line_tools_temp_file" ]; then
            rm "$cmd_line_tools_temp_file"
	    fi
    fi

    # Installing the latest Xcode command line tools on 10.7.x and 10.8.x

    # on 10.7/10.8, instead of using the software update feed, the command line tools are downloaded
    # instead from public download URLs, which can be found in the dvtdownloadableindex:
    # https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex

    if [ "$osx_vers" -eq 7 ] || [ "$osx_vers" -eq 8 ]; then

	    if [ "$osx_vers" -eq 7 ]; then
	        DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
    	fi
	
	    if [ "$osx_vers" -eq 8 ]; then
	        DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg
	    fi

	    TOOLS=cltools.dmg
	    curl "$DMGURL" -o "$TOOLS"
    	TMPMOUNT=$(/usr/bin/mktemp -d /tmp/clitools.XXXX)
	    hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT" -nobrowse
    	# The "-allowUntrusted" flag has been added to the installer
	    # command to accomodate for now-expired certificates used
    	# to sign the downloaded command line tools.
	    installer -allowUntrusted -pkg "$(find "$TMPMOUNT" -name '*.mpkg')" -target /
	    hdiutil detach "$TMPMOUNT"
	    rm -rf "$TMPMOUNT"
	    rm "$TOOLS"
    fi
fi

# Does _brew exist?
if ! id -u "_brew"; then
	for (( uid = 500;; --uid )) ; do
    if ! id -u $uid &>/dev/null; then
        if ! dscl /Local/Default -ls Groups gid | grep -q [^0-9]$uid\$ ; then
          dscl /Local/Default -create "Groups/_brew"
          dscl /Local/Default -create "Groups/_brew" Password \*
          dscl /Local/Default -create "Groups/_brew" PrimaryGroupID $uid
          dscl /Local/Default -create "Groups/_brew" RealName ""
          dscl /Local/Default -create "Groups/_brew" RecordName "_brew" "_brew"

          dscl /Local/Default -create "Users/_brew"
          dscl /Local/Default -create "Users/_brew" NFSHomeDirectory /var/empty
          dscl /Local/Default -create "Users/_brew" Password \*
          dscl /Local/Default -create "Users/_brew" PrimaryGroupID $uid
          dscl /Local/Default -create "Users/_brew" RealName ""
          dscl /Local/Default -create "Users/_brew" RecordName "_brew" "_brew"
          dscl /Local/Default -create "Users/_brew" UniqueID $uid
          dscl /Local/Default -create "Users/_brew" UserShell /usr/bin/false

          dscl /Local/Default -delete "Users/_brew" AuthenticationAuthority
          dscl /Local/Default -delete "Users/_brew" PasswordPolicyOptions
          break
        fi
    fi
done
fi

# Is homebrew already installed?
if ! sudo -u "_brew" brew -v;then
    
    # Curl down the latest tarball and install to /usr/local/Homebrew
    mkdir /usr/local/Homebrew
    curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C /usr/local/Homebrew
    ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew

    # Manually make all the appropriate directories and set permissions
    mkdir -p /usr/local/Cellar /usr/local/Library /usr/local/var/homebrew/linked /usr/local/Frameworks /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chmod -R g+rwx /usr/local/Cellar /usr/local/Library /usr/local/var/homebrew /usr/local/Homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var
    chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
    chown -R "_brew:admin" /usr/local/Homebrew /usr/local/Cellar /usr/local/Library /usr/local/var/homebrew /usr/local/Frameworks /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/opt /usr/local/sbin /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var

    # Create a system wide cache folder
    mkdir -p /Library/Caches/Homebrew
    chmod g+rwx /Library/Caches/Homebrew
    chown -R "_brew":wheel /Library/Caches/Homebrew

	# Add the log
	mkdir /var/log/homebrew
	chown "_brew" /var/log/homebrew

    # Add flags for passwordless sudo for _brew
	echo "# Homebrew
%admin  ALL=(_brew) SETENV: /usr/local/bin/brew 
_brew ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

	# Create the "brewdo" command to use sudo -u _brew brew with args
	echo "#!/bin/sh
tmphome=\$(mktemp -d /tmp/_brew.XXXXXX)
chown -R _brew \$tmphome
cd \$tmphome || exit 1
if [ \"\$1\" = \"cask\" ] && [ \"\$2\" != \"remove\" ]; then
    CASK_ARGS='--appdir=\"/Applications\" --prefpanedir=\"/Library/PreferencePanes\" --qlplugindir=\"/Library/QuickLook\" --servicedir=\"/Library/Services\"'
else
    CASK_ARGS=''
fi
HOMEBREW_LOGS=/var/log/homebrew.log
sudo -u _brew HOME=\${tmphome} /usr/local/bin/brew \$@ \$CASK_ARGS
" > /usr/local/bin/brewdo

    chmod +x /usr/local/bin/brewdo

    # Install the MD5 checker or the recipes will fail
    /usr/local/bin/brewdo install md5sha1sum

else
    # Run an update and quit
    /usr/local/bin/brewdo update
    exit 0
fi

# Make sure everything is up to date
/usr/local/bin/brewdo update

# Get python3
/usr/local/bin/brewdo install python3

# No more caffeine please. I've a headache.
kill "$caffeinatepid"

exit 0
