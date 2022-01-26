#!/bin/sh

function setStatus () {
  if { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
    tmux set status-right "Status: $1"   
  fi

  echo "********** ----- Status: $1 ----- ***********"
  echo "$1" >> 'nexmoncsi_status.log'
}

setStatus "Downloading Nexmon"
git clone https://github.com/seemoo-lab/nexmon.git
cd nexmon
NEXDIR=$(pwd)

setStatus "Building libISL"
cd $NEXDIR/buildtools/isl-0.10
autoreconf -f -i
./configure
make
make install
ln -s /usr/local/lib/libisl.so /usr/lib/arm-linux-gnueabihf/libisl.so.10

setStatus "Building libMPFR"
cd $NEXDIR/buildtools/mpfr-3.1.4
autoreconf -f -i
./configure
make
make install
ln -s /usr/local/lib/libmpfr.so /usr/lib/arm-linux-gnueabihf/libmpfr.so.4

setStatus "Setting up Build Environment"
cd $NEXDIR
source setup_env.sh
make

setStatus "Downloading Nexmon_CSI"
cd $NEXDIR/patches/bcm43455c0/7_45_189/
git clone https://github.com/seemoo-lab/nexmon_csi.git

setStatus "Building and installing Nexmon_CSI"
cd nexmon_csi
make install-firmware

setStatus "Installing makecsiparams"
cd utils/makecsiparams
make
ln -s $PWD/makecsiparams /usr/local/bin/mcp

setStatus "Installing nexutil"
cd $NEXDIR/utilities/nexutil
make
make install

setStatus "Setting up Persistance"
cd $NEXDIR/patches/bcm43455c0/7_45_189/nexmon_csi/
cd brcmfmac_5.10.y-nexmon
mv $(modinfo brcmfmac -n) ./brcmfmac.ko.orig
cp ./brcmfmac.ko $(modinfo brcmfmac -n)
depmod -a

setStatus "Completed"
