#!/usr/bin/env bash

if [ -z "$GITHUB_API_TOKEN" ]; then
    echo "Set GITHUB_API_TOKEN to a GitHub OAuth token authorized to access ldc-developers/ldc."
    exit 1
fi

if [ -z "$GITHUB_RELEASE_ID" ]; then
    cat <<-EOM
Set GITHUB_RELEASE_ID to the GitHub-internal ID of the release in question.

You can fetch a list of all releases by running:

curl -i -H "Authorization: token \${GITHUB_API_TOKEN}" \\
    -H "Accept: application/vnd.github.manifold-preview" \\
    "https://api.github.com/repos/ldc-developers/ldc/releases"
EOM
    exit 1
fi

. env.sh

curl -H "Authorization: token ${GITHUB_API_TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -H "Content-Type: application/octet-stream" \
     --data-binary @$BUILD_ROOT/$PKG_BASE.tar.gz \
     "https://uploads.github.com/repos/ldc-developers/ldc/releases/${GITHUB_RELEASE_ID}/assets?name=$PKG_BASE.tar.gz"

curl -H "Authorization: token ${GITHUB_API_TOKEN}" \
     -H "Accept: application/vnd.github.manifold-preview" \
     -H "Content-Type: application/octet-stream" \
     --data-binary @$BUILD_ROOT/$PKG_BASE.tar.xz \
     "https://uploads.github.com/repos/ldc-developers/ldc/releases/${GITHUB_RELEASE_ID}/assets?name=$PKG_BASE.tar.xz"
