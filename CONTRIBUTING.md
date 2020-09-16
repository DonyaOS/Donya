# Contributing

- [Markdownlint](https://www.npmjs.com/package/markdownlint-cli)
- [Shellcheck](https://github.com/koalaman/shellcheck)
- [yamllint](https://yamllint.readthedocs.io/en/stable/)

We use `markdownlint` to lint the [Markdown](https://daringfireball.net/projects/markdown/):

```
markdownlint '**/*.md' --ignore node_modules --fix --config .github/.markdownlint.yml
```

We also use `yamllint` to lint the [YAML](https://yaml.org/) files:

```
yamllint -c .github/.yamllint .
```

We use `shellcheck` to lint the [shell script](https://en.wikipedia.org/wiki/Shell_script) files:

```
shellcheck donya.sh
```
