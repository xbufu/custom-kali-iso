# Custom Kali ISO

## OffSec Guide

https://www.offensive-security.com/kali-linux/kali-rolling-iso-of-doom/

## Instructions

### Install Requirements

```bash
sudo apt-get install git live-build cdebootstrap
```

### Clone live-build-config Repository

```bash
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git build/
cd build/
```

### Apply Patch to Fix Setup

```bash
patch -p1 < ../config.patch
```

### Create Boot Menu Entry

```bash
cp ../install.cfg kali-config/common/includes.binary/isolinux/install.cf
cp ../isolinux.cfg kali-config/common/includes.binary/isolinux/isolinux.cfg
```

### Add Preseed File

```bash
cp ../preseed.cfg kali-config/common/includes.installer/preseed.cfg
```

### Build the ISO

```bash
./build.sh --distribution kali-rolling --verbose
```