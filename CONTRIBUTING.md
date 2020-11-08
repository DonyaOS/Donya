# Contributing

## Pre-commit

<https://pre-commit.com>

```
pre-commit install
```

So far we are only checking Markdown files in the pre-commit run.

## GitHub Actions

- [Markdownlint](https://www.npmjs.com/package/markdownlint-cli)
- [Shellcheck](https://github.com/koalaman/shellcheck)
- [yamllint](https://yamllint.readthedocs.io/en/stable/)

We use `markdownlint` to lint the [Markdown](https://daringfireball.net/projects/markdown/):

```
markdownlint '**/*.md' --ignore node_modules --fix
```

We also use `yamllint` to lint the [YAML](https://yaml.org/) files:

```
yamllint .
```

We use `shellcheck` to lint the [shell script](https://en.wikipedia.org/wiki/Shell_script) files:

```
shellcheck donya.sh
```
