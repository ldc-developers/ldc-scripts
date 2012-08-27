#!/bin/bash
#
# Updates the LDC dmd-testsuite repository at
# https://github.com/ldc-developers/dmd-testsuite
# with the latest commits from the upstream DMD repository.
#
# DMD_CLONE allows the user to override the directory the DMD clone resides
# in (a fresh clone is made if not present), TESTSUITE_TMP controls the
# temporary directory used to perform the Git history rewriting.
#
# Author: David Nadlinger <code@klickverbot.at>
#

set -e

if [ -z "$DMD_CLONE" ]
then
    DMD_CLONE=$(pwd)/dmd
fi
if [ -z "$TESTSUITE_TMP" ]
then
    TESTSUITE_TMP=/tmp/dmd-testsuite.tmp
fi

if [ -e "$TESTSUITE_TMP" ]
then
    echo "Temporary directory $TESTSUITE_TMP already exists, aborting..."
    exit 1
fi

if [ ! -e "$DMD_CLONE" ]
then
    git clone https://github.com/D-Programming-Language/dmd.git $DMD_CLONE
fi

# Update the DMD repository and create a clone to operate on.
cd $DMD_CLONE
git pull origin
git clone --bare $DMD_CLONE $TESTSUITE_TMP

# Perform the rewrite – there seems to be no way to do this incrementally, we
# process the whole history every time.
cd $TESTSUITE_TMP
echo "Invoking git filter-branch, this might take some time..."
REWRITE_LOG=$(git filter-branch --tag-name-filter cat --prune-empty --subdirectory-filter test -- --all 2>&1)
echo "done."

# Delete tags which were not touched because they never contained a test/
# directory.
echo "$REWRITE_LOG" | grep "WARNING: Ref 'refs/tags/.*'is unchanged" |\
    sed -e "s,WARNING: Ref 'refs/tags/,,g" -e "s,' is unchanged,,g" |\
    xargs git tag -d

# Remove tags where the tree is empty. This takes care of cases (in particular
# the later D1 tags) where the test/ directory once existed but was removed
# again.
EMPTY_TREE="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
for tag in $(git tag -l)
do
    if [ "$(git rev-parse $tag^{tree})" = "$EMPTY_TREE" ]
    then
        git tag -d $tag
    fi
done

# Push updates to the GitHub repository.
git remote add dmd-testsuite git@github.com:ldc-developers/dmd-testsuite.git
git push --all dmd-testsuite
git push --tags dmd-testsuite

rm -rf $TESTSUITE_TMP
