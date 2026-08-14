# magento2-github-actions

## Coding Standard
Runs the Magento Coding Standard (`Magento2` sniffs) against changed files on a pull request,
or a full directory otherwise, and reports results inline on the PR via `cs2pr`.

### Usage
```
name: Magento 2 Coding Standards Test
on:
  pull_request:
    branches:
      - staging
      - production

permissions:
  contents: read

jobs:
  static:
    name: Static Code Analysis PHPCS
    runs-on: ubuntu-latest
    steps:
      - name: Coding Standard
        uses: HSF-Digital-Team/github-actions/coding-standard@main
        with:
          php_version: "8.4"
          path: 'app/code'
```

Inputs:
- `php_version` (default `8.4`)
- `composer_version` (default `2`)
- `path` (required, default `app/code`) — directory checked when the event is not a pull request
- `version` — `magento/magento-coding-standard` version to install (default `37`)
- `extensions` — restrict PHPCS to specific extensions (default `*`)

## PHPCompatibility
Runs the [PHPCompatibility](https://github.com/PHPCompatibility/PHPCompatibility) standard against
changed files on a pull request, or a full directory otherwise, checking code against a target PHP version.

### Usage
```
name: PHP Compatibility Test
on:
  pull_request:
    branches:
      - staging
      - production

permissions:
  contents: read

jobs:
  static:
    name: PHP Compatibility Check
    runs-on: ubuntu-latest
    steps:
      - name: PHPCompatibility
        uses: HSF-Digital-Team/github-actions/php-compatibility@main
        with:
          php_version: "8.4"
```

Inputs:
- `php_version` (default `8.4`) — also used as the `testVersion` target for compatibility checks
- `composer_version` (default `2`)
- `version` — `magento/magento-coding-standard` version to install, which provides the PHPCompatibility standard (default `40`)
- `path` (default `${{ github.workspace }}/project`) — directory checked when the event is not a pull request

## Hyva Coding Standard
Runs the [Hyva Themes Coding Standard](https://github.com/hyva-themes/hyva-coding-standard) against
changed `.phtml`/`.php` files on a pull request, or a full directory otherwise.

### Usage
```
name: Hyva Coding Standards Test
on:
  pull_request:
    branches:
      - staging
      - production

permissions:
  contents: read

jobs:
  static:
    name: Static Code Analysis Hyva
    runs-on: ubuntu-latest
    steps:
      - name: Hyva Coding Standard
        uses: HSF-Digital-Team/github-actions/hyva-coding-standard@main
        with:
          php_version: "8.4"
```

Inputs:
- `php_version` (default `8.4`)
- `composer_version` (default `2`)
- `path` (default `${{ github.workspace }}/project/app/design`) — directory checked when the event is not a pull request
- `extensions` (default `phtml,php`)
- `ignore` (default `*/node_modules/*`)
- `exclude` (default `Generic.Files.LineLength,Magento2.Annotation.MethodAnnotationStructure`)

Both `Coding Standard` and `Hyva Coding Standard` can run as separate steps in the same job to lint
Magento PHP and Hyva templates together.

## Update Changelog
On each release, the file CHANGELOG.md is updated with the content of the release tag.
