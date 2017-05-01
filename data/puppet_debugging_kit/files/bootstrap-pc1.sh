#! /bin/bash

# This script installs the Puppet Labs PC1 repository onto the following
# systems:
#
#   - rpm: CentOS, Fedora, etc.
#   - deb: Debian, Ubuntu, etc.
#
# Once installed, the repo provides easy access to Puppet Agent and Puppet
# Server packages.

if [ -f /etc/redhat-release ]; then
  PKG_SYS='yum'
elif [ -f /etc/debian_version ]; then
  PKG_SYS='apt'
else
  echo 'The poss-pc1-repos role only works on Debian or RedHat systems!'
  exit 1
fi

case $PKG_SYS in
  yum)
    if rpm --quiet -q puppetlabs-release-pc1; then
      echo 'Puppet Labs PC1 repo present.'
    else
      if [ -f /etc/fedora-release ]; then
        RH_DIST='fedora'
      else
        RH_DIST='el'
      fi
      RH_VERS=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
      echo "Adding Puppet Labs repo for $RH_DIST $RH_VERS."
      rpm -ivh "http://yum.puppetlabs.com/puppetlabs-release-pc1-$RH_DIST-$RH_VERS.noarch.rpm"
    fi
    ;;
  apt)
    if dpkg -s puppetlabs-release-pc1 2>/dev/null | grep -q '^Status:.* installed'; then
      echo 'Puppet Labs PC1 repo present.'
    else
      DEB_RELEASE=$(lsb_release -c -s)
      echo "Adding Puppet Labs repo for $DEB_RELEASE."
      apt-get install -y curl
      curl -O "http://apt.puppetlabs.com/puppetlabs-release-pc1-$DEB_RELEASE.deb"
      dpkg -i "puppetlabs-release-pc1-$DEB_RELEASE.deb"
      apt-get -y -m update
    fi
    ;;
esac
