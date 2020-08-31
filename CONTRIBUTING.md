# Contributing

- [Markdownlint](https://www.npmjs.com/package/markdownlint-cli)
- [Shellcheck](https://github.com/koalaman/shellcheck)
- [yamllint](https://yamllint.readthedocs.io/en/stable/)

We use Markdownlint to lint the Markdown:

```
markdownlint '**/*.md' --ignore node_modules --fix
```

And we also use yamllint to lint the yml files:

```
yamllint .
```

We use shellcheck to lint the shell script files:

```
shellcheck donya.sh
```
