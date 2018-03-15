#!/bin/bash

set -ex

#clone the repo and create new branch
mkdir -p $GOPATH/src/github.com/$1
cd $GOPATH/src/github.com/$1
rm -rf $2
git clone git@github.com:$1/$2.git
cd $2
git checkout -b travis-tahsin-1

#add converage.txt to the end of .gitignore
echo "coverage.txt" >> .gitignore

#add new file .travis.yml
cat > .travis.yml <<EOF
language: go
go:
 - 1.x
 - tip

install: true

script:
  - go build ./...
  - ./hack/coverage.sh

after_success:
  - bash <(curl -s https://codecov.io/bash)
EOF

#edit readme.md

#DELETE badges
sed -i '/\[\!\[Go Report Card\]/ d' README.md
sed -i '/\[\!\[Build Status\]/ d' README.md
sed -i '/\[\!\[codecov\]/ d' README.md
sed -i '/\[\!\[Docker Pulls\]/ d' README.md
sed -i '/\[\!\[Slack\]/ d' README.md
sed -i '/\[\!\[Twitter\]/ d' README.md

#ADD STATUS BADGES
sed -i "1s/^/[![Go Report Card](https:\/\/goreportcard.com\/badge\/github.com\/$1\/$2)](https:\/\/goreportcard.com\/report\/github.com\/$1\/$2)\n/" README.md
sed -i "2s/^/[![Build Status](https:\/\/travis-ci.org\/$1\/$2.svg?branch=master)](https:\/\/travis-ci.org\/$1\/$2)\n/" README.md
sed -i "3s/^/[![codecov](https:\/\/codecov.io\/gh\/$1\/$2\/branch\/master\/graph\/badge.svg)](https:\/\/codecov.io\/gh\/$1\/$2)\n/" README.md
sed -i "4s/^/[![Docker Pulls](https:\/\/img.shields.io\/docker\/pulls\/$1\/$2.svg)](https:\/\/hub.docker.com\/r\/$1\/$2\/)\n/" README.md
sed -i "5s/^/[![Slack](https:\/\/slack.appscode.com\/badge.svg)](https:\/\/slack.appscode.com)\n/" README.md
sed -i "6s/^/[![Twitter](https:\/\/img.shields.io\/twitter\/follow\/appscodehq.svg?style=social\&logo=twitter\&label=Follow)](https:\/\/twitter.com\/intent\/follow?screen_name=AppsCodeHQ)\n/" README.md

#change glide-slow
cat > glide-slow <<EOF
#!/usr/bin/env bash

# You can execute me through Glide by doing the following:
# - Execute \`glide slow\`
# - ???
# - Profit

pushd \$GOPATH/src/github.com/$1/$2

glide up -v
glide vc --use-lock-file --only-code --no-tests

popd
EOF


#ADD hack/coverage.sh
if [ ! -d hack ]
then
    mkdir hack
fi

cat > hack/coverage.sh <<EOF
#!/usr/bin/env bash
set -eou pipefail

GOPATH=\$(go env GOPATH)
REPO_ROOT="\$GOPATH/src/github.com/$1/$2"

pushd \$REPO_ROOT

echo "" > coverage.txt

for d in \$(go list ./... | grep -v -e vendor -e test); do
    go test -v -race -coverprofile=profile.out -covermode=atomic "\$d"
    if [ -f profile.out ]; then
        cat profile.out >> coverage.txt
        rm profile.out
    fi
done

popd
EOF
chmod +x hack/coverage.sh

#RUN glide slow
chmod +x glide-slow
glide slow

git add --all
git commit -m 'Add travis yaml'
git push --set-upstream origin travis-tahsin-1
