#!/usr/bin/env bash

set -x

branch_name=update-pipeline
curr_dir=$(pwd)

# log into team
function login() {
    for team in main kubedb appscode kube-ci kubevault; do
        fly -t $team login -n $team -c https://concourse.appscode.com
    done
}

function update_pipeline() {
    pushd $REPO_ROOT

    git checkout master
    git pull origin master
    git branch -D $branch_name # remove local branch
    git push origin --delete $branch_name # remove remote branch
    git checkout -b $branch_name

    # update pipeline config
    cp $curr_dir/$template.yml hack/concourse/pipeline.yml
    sed -i "s/\$repo/$repo/g" hack/concourse/pipeline.yml
    sed -i "s/\$org/$team/g" hack/concourse/pipeline.yml

    # update pipeline
    fly -t $team sp -p $repo -c hack/concourse/pipeline.yml -l ~/secret/cred.yml

    # git push
    git add --all
    git commit -m 'update pipeline'
    git push --set-upstream origin $branch_name

    popd
}

login

for repo in mysql mongodb redis memcached postgres elasticsearch operator service-broker user-manager; do
    team=kubedb
    template=kubedb
    REPO_ROOT=$GOPATH/src/github.com/kubedb/$repo
    update_pipeline
done

for repo in voyager stash kubed searchlight; do
    team=appscode
    template=template
    REPO_ROOT=$GOPATH/src/github.com/appscode/$repo
    update_pipeline
done

for repo in kubeci git-apiserver; do
    team=kube-ci
    template=template
    REPO_ROOT=$GOPATH/src/kube.ci/$repo
    update_pipeline
done

for repo in operator; do
    team=kubevault
    template=template
    REPO_ROOT=$GOPATH/src/github.com/kubevault/$repo
    update_pipeline
done

$@
