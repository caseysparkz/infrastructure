// A generated module for Docker functions

package main

import (
	"context"
	"dagger/docker/internal/dagger"
	"fmt"
)

var mountPoint = "/mnt"

func New(
	// Project source directory
	// +optional
	// +ignore=["*cache*",".coverage",".env",".git",".terraform",".venv","build","dist","node_modules","*.log"]
	// +defaultPath="/"
	source *dagger.Directory,
) *Docker {
	return &Docker{
		Source: source,
	}
}

type Docker struct {
	Source *dagger.Directory
}

// Runs hadolint (Dockerfile linter) against files.
func (m *Docker) Hadolint(
	ctx context.Context,
	// Files to lint.
	file []string,
	// Version of Hadolint to use.
	// +optional
	// +default="2.14.0"
	hadolintVersion string,
) (string, error) {

	return dag.Container().
		From(fmt.Sprintf("ghcr.io/hadolint/hadolint:v%s", hadolintVersion)).
		WithMountedDirectory(mountPoint, m.Source).
		WithWorkdir(mountPoint).
		WithExec(append([]string{"hadolint", "--no-color"}, file...)).
		Stdout(ctx)
}

// Checks the validity of a docker compose file.
func (m *Docker) ComposeConfig(
	ctx context.Context,
	// File to lint.
	file string,
	// Version of docker-compose to use.
	// +optional
	// +default="latest"
	composeVersion string,
) (string, error) {

	return dag.Container().
		From(fmt.Sprintf("docker.io/docker/compose:%s", composeVersion)).
		WithMountedDirectory(mountPoint, m.Source).
		WithWorkdir(mountPoint).
		WithExec([]string{"docker", "compose", file}).
		Stdout(ctx)
}
