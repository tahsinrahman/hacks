package main

import (
	"fmt"
	"log"
	"os/exec"
)

type org struct {
	name string
	repo []string
}

func main() {
	list := []org{
		{
			name: "kubedb",
			repo: []string{"cli", "operator", "postgres", "apimachinery", "elasticsearch", "mysql", "mongodb", "redis", "memcached", "kubedb-server"},
		},
		{
			name: "kubepack",
			repo: []string{"pack", "pack-server", "onessl"},
		},
		{
			name: "appscode",
			repo: []string{"kubed", "swift", "concourse-git-pr-resource", "grpc-go-addons", "steward", "go-notify", "osm", "g2", "go-dns"},
		},
		{
			name: "pharmer",
			repo: []string{"pharmer", "cloud-controller-manager", "cloud-storage", "flexvolumes", "pre-k", "swanc"},
		},
	}

	for _, orgName := range list {
		for _, repoName := range orgName.repo {
			fmt.Println(orgName.name, repoName)
			cmd := exec.Command("./replicate.sh", orgName.name, repoName)

			err := cmd.Run()
			if err != nil {
				log.Fatal(err)
			}
		}
	}
}
