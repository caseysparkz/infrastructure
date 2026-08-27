// A generated module for Compliance functions
//
// This module runs Anchore's Syft, Grype, etc. modules against the project
// source, generating SBOMs and licence data from dependencies.

package main

import (
	"context"
	"dagger/compliance/internal/dagger"
	"fmt"
)

var mountPoint = "/mnt"

func New(
	// Version of Grype to use.
	// +optional
	// +default="0.116.0"
	grypeVersion string,
	// Version of Syft to use.
	// +optional
	// +default="1.49.0"
	syftVersion string,
	// Repository root dir.
	// +optional
	// +ignore=["*cache*",".coverage",".env",".git*",".terraform",".venv","build","dist","node_modules","*.log"]
	// +defaultPath="/"
	source *dagger.Directory,
) *Compliance {
	return &Compliance{
		GrypeVersion: grypeVersion,
		SyftVersion:  syftVersion,
		Source:       source,
	}
}

type Compliance struct {
	GrypeVersion string
	SyftVersion  string
	Source       *dagger.Directory
}

// Runs Syft inside dagger to generate a software bill of materials (SBOM)
func (m *Compliance) sbomFile() *dagger.File {
	syftCacheDir := "%s/.cache/syft"
	syftImage := fmt.Sprintf("docker.io/anchore/syft:v%s", m.SyftVersion)

	return dag.Container().
		From(syftImage).
		WithMountedDirectory(mountPoint, m.Source).
		WithMountedCache(syftCacheDir, dag.CacheVolume(syftImage)).
		WithEnvVariable("SYFT_CACHE_DIR", syftCacheDir).
		WithWorkdir(mountPoint).
		WithExec([]string{"/syft", "scan", "."}).
		File("./spdx.json")
}

// TODO: implement
// func (m *Compliance) Grype(ctx context.Context) (string, error) {}

// Returns the contents of the Syft (SPDX) SBOM (JSON)
func (m *Compliance) Sbom(ctx context.Context) (string, error) {
	sbomPath := "/sbom.json"

	return dag.Container().
		From("docker.io/imega/jq:latest").
		WithMountedFile(sbomPath, m.sbomFile()).
		WithExec([]string{"jq", ".", sbomPath}).
		Stdout(ctx)
}
