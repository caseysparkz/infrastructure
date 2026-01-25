"""Dagger classes and functions."""

from typing import Annotated

from dagger import DefaultPath, Directory, check, dag, function, object_type


@object_type
class Infrastructure:
    """Infrastucture module."""

    @function
    @check
    async def lint_terraform(
        self,
        repo_dir: Annotated[Directory, DefaultPath(".")],
        modules: list[str],
    ) -> list[str]:
        """Run `terraform validate` across a list of modules.

        Arguments:
            repo_dir:   Base directory to mount inside Dagger.
            aws_dir:    AWS directory containing auth creds.
            modules:    List of module paths to validate.

        Returns:
            List of stdout responses.
        """
        mnt_dir = "/mnt"
        container = (
            dag.container()
            .from_("hashicorp/terraform:1.14.3")
            .with_mounted_directory(mnt_dir, repo_dir)
            .without_files(["**/.terraform*"])
        )

        return {
            module: await container.with_workdir(f"/{mnt_dir}/{module}/")
            .with_exec(["terraform", "init", "--backend=false"])
            .with_exec(["terraform", "validate"])
            .stdout()
            for module in modules
        }

    @function
    @check
    def lint_python(self) -> None:
        """Lint Python files with `ruff check .`."""
        return dag.ruff()

    @function
    @check
    async def security_scan(self, severity: str = "HIGH,CRITICAL") -> None:
        """Runs security scan with optional severity filter."""
        await (
            dag.container()
            .from_("aquasec/trivy:latest")
            .with_exec(["trivy", "fs", "--severity", severity, "."])
            .sync()
        )
