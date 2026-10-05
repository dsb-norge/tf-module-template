# Development of module

Below you can find basic guidelines and rules that must be followed during module development.

## Validate your code

```shell
  # Init project, run fmt and validate
  terraform init -reconfigure
  terraform fmt -recursive
  terraform validate

  # Lint with TFLint, calling script from https://github.com/dsb-norge/terraform-tflint-wrappers
  alias lint='curl -s https://raw.githubusercontent.com/dsb-norge/terraform-tflint-wrappers/main/tflint_linux.sh | bash -s --'
  lint

  # Validate all example directories
  for example_dir in examples/*/; do
    dir_name=${example_dir%*/}
    if ! terraform -chdir=${dir_name} init; then echo "terraform init failed in ${dir_name}"; break; fi
    if ! terraform -chdir=${dir_name} validate; then echo "terraform validate failed in ${dir_name}"; break; fi
    if ! terraform -chdir=${dir_name} fmt -check; then echo "terraform fmt check failed in ${dir_name}"; break; fi
    if ! .tflint/tflint -chdir=${dir_name} --config .tflint.hcl; then echo "tflint failed in ${dir_name}"; break; fi
  done

  # Manually test all examples
  az account set --subscription 'GUID HERE'
  for example_dir in examples/*/; do
    dir_name=${example_dir%*/}
    if ! terraform -chdir=${dir_name} init; then echo "terraform init failed in ${dir_name}"; break; fi
    if ! ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform -chdir=${dir_name} apply; then echo "terraform apply failed in ${dir_name}"; break; fi
    if ! ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform -chdir=${dir_name} destroy; then echo "terraform destroy failed in ${dir_name}"; break; fi
  done

  # Run the unit tests, which need no credentials
  terraform test -filter=tests/unit-tests.tftest.hcl

  # Run every test using built-in terraform testing framework
  az account set --subscription 'GUID HERE'
  ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv) terraform test

```

## Tests

The module needs at least one test file: CI fails without one. `tests/unit-tests.tftest.hcl` is the
unit suite; it plans the module without credentials, with its providers mocked (`mock_provider`)
once the module requires any. CI runs every file named `unit-*.tftest.hcl` in the `unit` lane, which has none, and
every other test file in the `integration` lane, whose credentials are the secrets of the GitHub
Environment `tftest-integration` (see `.github/workflows/test.yaml`). Put test files in `tests/`, or
beside the module's `.tf` files; a file anywhere else is listed as misplaced and does not run.

## Release and versioning

This module uses [semantic versioning](https://semver.org).
Always use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) in your pull-requests.
Module is using [release-please action](https://github.com/googleapis/release-please-action) and it create release PR based on commit message after PR is merged to main.
Use [respective conventional commits](https://github.com/googleapis/release-please?tab=readme-ov-file#how-should-i-write-my-commits) to achieve correct [SemVer](https://semver.org) release version.

Refer to [release-please documentation](https://github.com/googleapis/release-please) for better understanding and when additional questions occur.

## Dependencies and versions

The full strategy, with the reasons, is
[Module dependencies](https://github.com/dsb-norge/github-actions-terraform/blob/main/docs/Module-dependencies.md)
in github-actions-terraform. In short:

- **Providers get a range over one major**, `version = ">= 4.0.0, < 5.0.0"`, with `source` and
  `version` on lines of their own. Never pin a provider exactly: every caller of the module would be
  bound to that version.
- **No lock file.** Callers decide with their own lock file; CI here always installs the newest
  release in the range, and the weekly scheduled run tests it.
- **Modules this module calls are pinned exactly**, `version = "0.4.4"`.

What happens on its own:

- **Dependabot** proposes new versions of the called modules, never of a provider and never a
  major, as `fix(deps)` commits, so each merged bump is released as a patch.
- **The Dependabot admission** judges each of its pull requests before anything runs it (allowed
  publisher, at least three days old, signed like the version before).
- **With auto-merge switched on** in `.github/workflows/test.yaml`, an admitted, green Dependabot
  pull request that stays within each dependency's major merges itself, and so does the release
  pull request that follows; the `Create test matrix` job's notice says why one does not.

When to act:

| When | Do |
|---|---|
| A Dependabot pull request waits because it moves a 0.x module's minor or a major | Read the called module's release notes, check the tests, and merge it. If it changes what callers get, push a commit saying so (`feat:`, or `feat!:` with a `BREAKING CHANGE:` footer). |
| The weekly scheduled run is red | A provider release broke the module or its tests: fix it in a pull request (`fix:`), or cap the range below that release until it is fixed. |
| A provider's next major is out and callers are moving | Widen the range (`< 6.0.0`, a `feat:` release) when the module works with both majors, or move it (`>= 5.0.0, < 6.0.0`, a `feat!:` release) when it needs the new one. |
| The module needs a newer provider feature | Raise the floor in the same pull request, a `feat:` release. |
| A release pull request waits | It changes more than the changelog; review and merge it. |

## Documentation

Repo CI action has step to generate terraform documentation automatically using [terraform-docs action](https://github.com/terraform-docs/gh-actions) and configuration files in repo.
It is, however, possible to run ```terraform-docs``` locally to check documentation during development or when other need occur.

### Generate and inject terraform-docs in README.md

```shell
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.20.0
export PATH=$PATH:$(go env GOPATH)/bin

# root
terraform-docs .

# docs for examples
for ex_dir in $(find "./examples" -maxdepth 1 -mindepth 1 -type d | sort); do
  terraform-docs "${ex_dir}" --config ./examples/.terraform-docs.yml
done
```
