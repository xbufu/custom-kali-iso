# Custom Kali ISO

This ISO will install a custom version of Kali with the selected packages and the default `root` user account. It will also load and apply the configurations defined in `postseed.sh`, which will be hosted remotely on a webserver.

You can customize the install options like locale, keyboard layou, user accounts and installed packages in the `preseed.cfg` file.

Any other configurations should be made through the `postseed.sh` file.

## Build Instructions

```bash
# Install Requirements
sudo apt install -y git live-build cdebootstrap

# Clone live-build-config Repository
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git build/
cd build/

# Apply Patch to Fix Setup
patch -p1 -R < ../config.patch

# Create Boot Menu Entry
cp ../install.cfg kali-config/common/includes.binary/isolinux/install.cfg
cp ../isolinux.cfg kali-config/common/includes.binary/isolinux/isolinux.cfg

# Clear package list for live image
echo '' > kali-config/variant-default/package-lists/kali.list.chroot

# Add Preseed File (Make sure to change the IP if you're using the postseed file)
cp ../preseed.cfg kali-config/common/includes.installer/preseed.cfg

# Build the ISO
./build.sh -v
```

### Host Postseed File on Webserver

```bash
sudo python3 -m http.server 80
```

## References

- https://www.offensive-security.com/kali-linux/kali-rolling-iso-of-doom/
- https://wiki.debian.org/DebianInstaller/Preseed
- https://d-i.debian.org/doc/installation-guide/en.amd64/apbs03.html
- https://www.debian.org/releases/stable/amd64/apb.en.html
- https://debian-live-config.readthedocs.io/en/latest/custom.html
