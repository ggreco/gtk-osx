#!/bin/sh
#
# Script that sets up jhbuild, and the jhbuildrc files and moduleset
# files as symlinks from the git repository.  This version is for
# maintainers of the setup. If you are a user, just run the
# gtk-osx-build-setup.sh script.
#
# Copyright 2007, 2008 Imendio AB
#

SOURCE=$HOME/Source

do_exit()
{
    echo $1
    exit 1
}

if test x`which git` == x; then
    do_exit "Git isn't available, please install it and try again."
fi

if test ! -d $SOURCE; then
    do_exit "The directory $SOURCE does not exist, please create it and try again."
fi

#JHBUILD_REVISION=`cat $SOURCE/gtk-osx-build/jhbuild-revision 2>/dev/null`
#if test x"$JHBUILD_REVISION" = x; then
#    do_exit "Could not find jhbuild revision to use."
#fi
#
#JHBUILD_REVISION_OPTION="-r$JHBUILD_REVISION"
#
echo "Checking out jhbuild ($JHBUILD_REVISION) from git..."
if ! test -d $SOURCE/jhbuild; then
    (cd $SOURCE ; git clone https://gitlab.gnome.org/GNOME/jhbuild )
else
    (cd $SOURCE/jhbuild && git pull >/dev/null)
fi

echo "Installing jhbuild..."
(cd $SOURCE/jhbuild && make -f Makefile.plain DISABLE_GETTEXT=1 install >/dev/null)

echo "Installing jhbuild configuration..."
ln -sfh `pwd`/jhbuildrc-gtk-osx $HOME/.jhbuildrc
ln -sfh `pwd`/jhbuildrc-gtk-osx-fw-10.4 $HOME/.jhbuildrc-fw-10.4
ln -sfh `pwd`/jhbuildrc-gtk-osx-fw-10.4-test $HOME/.jhbuildrc-fw-10.4-test
ln -sfh `pwd`/jhbuildrc-gtk-osx-cfw-10.4 $HOME/.jhbuildrc-cfw-10.4
if [ ! -f $HOME/.jhbuildrc-custom ]; then
    cp jhbuildrc-gtk-osx-custom-example $HOME/.jhbuildrc-custom
fi

echo "Setting up modulesets..."
cd modulesets
for f in `ls *modules`; do
    ln -sfh `pwd`/$f $SOURCE/jhbuild/modulesets/
done

echo "Done."
