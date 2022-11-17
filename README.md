# project title

TODO: Project description.


## Resources and data sources

TODO: What resources this module creates and what data sources it uses.


## Usage

TODO: Code examples for minimal use-case as well as fully parameterised.


## Development

### Validate your code

```shell
  # Init project, run fmt and validate
  terraform init -reconfigure
  terraform fmt -check -recursive
  terraform validate

  # Lint with TFLint, calling script from https://github.com/dsb-norge/terraform-tflint-wrappers
  alias lint='curl -s https://raw.githubusercontent.com/dsb-norge/terraform-tflint-wrappers/main/tflint_linux.sh | bash -s --'
  lint

```

### Generate and inject terraform-docs in README.md

```shell
# go1.17+
go install github.com/terraform-docs/terraform-docs@v0.16.0
export PATH=$PATH:$(go env GOPATH)/bin
terraform-docs markdown table --output-file README.md .
```


### Release

After merge of PR to main use tags to release.

Use semantic versioning, see [semver.org](https://semver.org/). Always push tags and add tag annotations.

Example of patch release `v0.0.4`:
```bash
git checkout origin/main
git pull origin main
git tag -a 'v0.0.4'  # add patch tag, add change description
git tag -f -a 'v0.0' # move the minor tag, amend the change description
git tag -f -a 'v0'   # move the major tag, amend the change description
git push -f --tags   # force push the new tags
```

Example of major release `v1.0.0`:
```bash
git checkout origin/main
git pull origin main
git tag -a 'v1.0.0'  # add patch tag, add your change description
git tag -a 'v1.0'    # add minor tag, add your change description
git tag -a 'v0'      # add major tag, add your change description
git push --tags      # push the new tags
```

**Note:** If you are having problems pulling main after a release, try to force fetch the tags: `git fetch --tags -f`.


# terraform-docs

<!-- BEGIN_TF_DOCS -->
this content between the `BEGIN_TF_DOCS` and `END_TF_DOCS` comments will be replaced by the auto-generated tf docs created by the [terraform-docs command](#generate-and-inject-terraform-docs-in-readmemd)
<!-- END_TF_DOCS -->