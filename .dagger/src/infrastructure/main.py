"""Dagger Infrastructure functions."""

from typing import Annotated

import dagger
from dagger import DefaultPath, Doc, check, dag, function, object_type

MNT = "/mnt"


class Docs:
    """Documentation for :class Infrastructure: vars."""

    mount: Doc = Doc("Directory to mount inside dagger. Defaults to dagger.json dir.")
    tf_dir: Doc = Doc("Directory to run Terraform inside, relative to :arg mount:")
    var_file: Doc = Doc("File to pass as tfvars. Relative to :arg tf_dir:")
    aws_access_key_id: Doc = Doc("AWS access key ID.")
    aws_secret_access_key: Doc = Doc("AWS secret access key.")
    aws_session_token: Doc = Doc("Optional AWS session token. Use if passing SSO session into container.")


@object_type
class Infrastructure:
    """Infrastructure class for Dagger."""

    @function
    async def terraform_validate(self, tf_dir: Annotated[str, Docs.tf_dir]) -> str:
        """Run `terraform validate` against a manifest or module."""
        return await (
            dag.container()
            .from_("hashicorp/terraform:latest")
            .with_mounted_directory(MNT, tf_dir)
            .with_workdir(MNT)
            .with_exec(["terraform", "init", "--backend=false"])
            .with_exec(["terraform", "validate"])
            .stdout()
        )

    @function
    async def terraform_test(self, tf_dir: Annotated[dagger.Directory, Docs.tf_dir]) -> str:
        """Run `terraform test` against a manifest or module."""
        return await (
            dag.container()
            .from_("hashicorp/terraform:latest")
            .with_mounted_directory(MNT, tf_dir)
            .with_workdir(MNT)
            .with_exec(["terraform", "init", "--backend=false"])
            .with_exec(["terraform", "test"])
            .stdout()
        )

    @function
    async def terraform_plan(  # noqa:PLR0913
        self,
        tf_dir: Annotated[dagger.Directory, Docs.tf_dir],
        aws_access_key_id: Annotated[dagger.Secret, Doc("AWS access key ID.")],
        aws_secret_access_key: Annotated[dagger.Secret, Doc("AWS secret access key.")],
        aws_session_token: Annotated[dagger.Secret | None, Docs.aws_session_token] = None,
        aws_region: Annotated[str, Doc("AWS region.")] = "us-west-2",
        var_file: Annotated[str | None, Docs.var_file] = None,
    ) -> str:
        """Run `terraform plan` against a manifest or module."""
        session_args = ("AWS_SESSION_TOKEN", aws_session_token) if aws_session_token else ("NOTSET", "")
        varfile_args = ["--var-file", var_file] if var_file else []

        return await (
            dag.container()
            .from_("hashicorp/terraform:latest")
            .with_secret_variable("AWS_ACCESS_KEY_ID", aws_access_key_id)
            .with_secret_variable("AWS_SECRET_ACCESS_KEY", aws_secret_access_key)
            .with_secret_variable(*session_args)
            .with_env_variable("AWS_REGION", aws_region)
            .with_mounted_directory(MNT, tf_dir)
            .with_workdir(MNT)
            .with_exec(["terraform", "init", "--upgrade"])
            .with_exec(["terraform", "plan", *varfile_args])
            .stdout()
        )

    @function
    async def terraform_apply(  # noqa:PLR0913
        self,
        tf_dir: Annotated[dagger.Directory, Docs.tf_dir],
        aws_access_key_id: Annotated[dagger.Secret, Doc("AWS access key ID.")],
        aws_secret_access_key: Annotated[dagger.Secret, Doc("AWS secret access key.")],
        aws_session_token: Annotated[dagger.Secret | None, Docs.aws_session_token] = None,
        aws_region: Annotated[str, Doc("AWS region.")] = "us-west-2",
        var_file: Annotated[str | None, Docs.var_file] = None,
    ) -> str:
        """Run `terraform apply` against a manifest or module."""
        session_args = ("AWS_SESSION_TOKEN", aws_session_token) if aws_session_token else ("NOTSET", "")
        varfile_args = ["--var-file", var_file] if var_file else []

        return await (
            dag.container()
            .from_("hashicorp/terraform:latest")
            .with_secret_variable("AWS_ACCESS_KEY_ID", aws_access_key_id)
            .with_secret_variable("AWS_SECRET_ACCESS_KEY", aws_secret_access_key)
            .with_secret_variable(*session_args)
            .with_env_variable("AWS_REGION", aws_region)
            .with_mounted_directory(MNT, tf_dir)
            .with_workdir(MNT)
            .with_exec(["terraform", "init", "--upgrade"])
            .with_exec(["terraform", "apply", *varfile_args])
            .stdout()
        )

    @function
    async def infracost_breakdown(
        self,
        mount: Annotated[dagger.Directory, Docs.mount, DefaultPath("/")],
        infracost_api_key: Annotated[dagger.Secret, Doc("Infracost API key.")],
        path: Annotated[dagger.Directory | None, Doc("Optional '--path' to pass to 'infracost breakdown'.")] = None,
    ) -> str:
        """Run `infracost breakdown` against all Terraform manifests."""
        infracost_args = ["--path", path] if path else ["--config-file", "infracost.yml"]

        return await (
            dag.container()
            .from_("infracost/infracost:latest")
            .with_mounted_directory(MNT, mount)
            .with_workdir(str(path) or MNT)
            .with_secret_variable("INFRACOST_API_KEY", infracost_api_key)
            .with_exec(["infracost", "breakdown", *infracost_args])
            .stdout()
        )

    @function
    @check
    async def lint_python(self) -> None:
        """Run `ruff check .` against all Python files."""
        await dag.container().from_("ghcr.io/astral-sh/ruff:0.15.7").with_exec(["ruff", "check", "."]).sync()

    @function
    @check
    async def format_python(self) -> None:
        """Run `ruff check .` against all Python files."""
        await (
            dag.container()
            .from_("ghcr.io/astral-sh/ruff:0.15.7")
            .with_exec(["uvx", "pip", "install", ".[test]"])
            .with_exec(["ruff", "format", "--check", "."])
            .sync()
        )

    @function
    @check
    async def format_terraform(self) -> str:
        """Run `terraform apply` against a manifest or module."""
        return await (
            dag.container().from_("hashicorp/terraform:latest").with_exec(["terraform", "fmt", "--recursive"]).sync()
        )
