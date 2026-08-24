// A generated module for Github functions
//
// This module performs specific operations against GitHub objects (pull requests, issues, etc.).

package main

import (
	"context"
	"dagger/github/internal/dagger"
	"fmt"
	"maps"
	"slices"
	"strings"
)

var mountPoint = "/mnt"
var tmpDir = "/tmp"

func New(
	// GitHub Token
	githubToken *dagger.Secret,
	// GH CLI Version
	// +optional
	// +default="2.98.0"
	ghCliVersion string,
	// Repository root dir.
	// +optional
	// +defaultPath="/"
	// +ignore["*cache*",".coverage",".env",".terraform/",".venv","build/","dist/","node_modules/","*.log"]
	source *dagger.Directory,
) *Github {
	return &Github{
		GithubToken:  githubToken,
		GhCliVersion: ghCliVersion,
		Image:        "debian:latest",
		Source:       source,
	}
}

type Github struct {
	GithubToken  *dagger.Secret
	GhCliVersion string
	Image        string
	Source       *dagger.Directory
}

// Get the intersection of two slices
func (m *Github) getPrCommitTypes(ctx context.Context) []string {
	validTypes := []string{ // Valid commit types
		"build",
		"chore",
		"ci",
		"docs",
		"feat",
		"fix",
		"perf",
		"refactor",
		"revert",
		"style",
		"test",
	}
	commitTypes := make(map[string]bool)

	var stdout, stderr = m.container().
		WithExec([]string{"gh", "pr", "view", "--json", "commits", "-q", ".commits[].messageHeadline"}).
		Stdout(ctx)

	if stderr != nil {
		return []string{""}
	}

	commitLog := strings.Split(stdout, "\n")

	for k := range commitLog {
		for j := range validTypes {
			if strings.HasPrefix(commitLog[k], validTypes[j]) {
				commitTypes[validTypes[j]] = true
			}
		}
	}

	return slices.Collect(maps.Keys(commitTypes))
}

// Returns a container with an initialized Git repository, and the GH CLI tool
func (m *Github) container() *dagger.Container {
	var ghDlPath = fmt.Sprintf("%s/gh.deb", tmpDir)
	var ghDlUrl = fmt.Sprintf(
		"https://github.com/cli/cli/releases/download/v%s/gh_%s_linux_amd64.deb",
		m.GhCliVersion,
		m.GhCliVersion,
	)

	return dag.Container().
		From(m.Image).
		WithMountedDirectory(mountPoint, m.Source).
		WithWorkdir(mountPoint).
		WithSecretVariable("GH_TOKEN", m.GithubToken).
		WithExec([]string{"apt-get", "update"}). // Update Apt lists
		WithExec([]string{                       // Install dependencies
			"apt-get", "upgrade", "--assume-yes", "--no-install-recommends",
			"ca-certificates", // Needed for wget
			"git",             // Needed for git
			"wget",            // Needed to install `gh`
		}).
		WithExec([]string{"wget", ghDlUrl, "-O", ghDlPath}). // Download GH CLI
		WithExec([]string{"dpkg", "-i", ghDlPath})           // Install GH CLI
}

// Automatically applies labels to a pull request
// +check
func (m *Github) LabelPr(ctx context.Context) (string, error) {
	commitTypes := m.getPrCommitTypes(ctx)

	stdout, stderr := m.container().
		WithExec([]string{"gh", "pr", "edit", "--add-label", strings.Join(commitTypes, ",")}). // Label PR
		Stdout(ctx)

	if stderr != nil {
		return "", stderr
	} else {
		return stdout, nil
	}
}
