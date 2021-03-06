#!/bin/bash

CURDIR=`pwd`
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GITROOT=$SCRIPTDIR/../../../..
cd $GITROOT
GITROOT=`pwd`

cd $GITROOT/fds/Source
git clean -dxf

cd $GITROOT/fds/Build
git clean -dxf

cd $GITROOT/bot/Bundle/fds/uploads
git clean -dxf

cd $GITROOT/smv/Source
git clean -dxf

cd $GITROOT/smv/Build
git clean -dxf

cd $GITROOT/bot/Bundle/smv/uploads
git clean -dxf

cd $CURDIR
