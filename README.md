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
- `ignore` — comma separated PHPCS ignore patterns. Defaults to
  `dev/*,docker/*,setup/*,lib/*` plus Magento's own bootstrap and entry-point files
  (`app/autoload.php`, `app/bootstrap.php`, `app/etc/NonComposerComponentRegistration.php`,
  `pub/*.php`, `pub/errors/*.php`, `phpserver/*.php`), which are shipped by
  `magento/magento2-base` and cannot be fixed in a project repo. Pass your own list to extend or
  replace it — the value replaces the default, so repeat the defaults you still want.

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
Adds release notes to a [Keep a Changelog](https://keepachangelog.com/) file using
the upstream `stefanzweifel/php-changelog-updater` CLI. Runs on the runner with
PHP 8.4 and `mbstring`, avoiding the upstream action's floating Docker image.
The CLI download is pinned to a source commit and verified with SHA-256.

### Usage

Replace `stefanzweifel/changelog-updater-action@v1` with
`HSF-Digital-Team/github-actions/changelog@main`. Existing `latest-version`
and `release-notes` inputs can stay as they are, or be omitted for release events.

```yaml
name: Update Changelog
on:
  release:
    types: [released]

permissions:
  contents: write
  pull-requests: write

jobs:
  changelog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
        with:
          ref: production

      - name: Update Changelog
        uses: HSF-Digital-Team/github-actions/changelog@main

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v8
        with:
          token: ${{ secrets.PUSH_TO_PROTECTED_BRANCH }}
          base: production
          branch: upgrade-changelog
          title: 'docs(changelog): update changelog for ${{ github.event.release.tag_name }}'
          add-paths: CHANGELOG.md
```

Use your repository's release branch in place of `production`. The caller checks
out the repository and decides how to commit or open a PR; this action only edits
the changelog. It needs no token or write permissions itself. PHP 8.4 becomes the
runner's active PHP version. Supported runners: Ubuntu with Bash, curl and PHP
support through `shivammathur/setup-php`.

Inputs:

| Input | Default | Description |
| --- | --- | --- |
| `latest-version` | Release event tag | Release tag; must be provided outside a release event. |
| `release-notes` | Release event body | Markdown notes; may be empty. |
| `path-to-changelog` | `CHANGELOG.md` | Path to the changelog in the checked-out repository. |
| `release-date` | Today | Optional date in `YYYY-MM-DD` format. |

For `workflow_dispatch`, explicitly pass the version and notes, since manual
runs do not have a release event payload. For example, expose `tag` and `notes`
as workflow inputs and pass `${{ inputs.tag }}` and `${{ inputs.notes }}` to
`latest-version` and `release-notes` respectively.

For a private actions repository, enable access from the consuming repositories
under **Settings → Actions → General → Access**. Use a commit SHA instead of
`@main` when you need an immutable action version.

The smoke test in `.github/workflows/test-changelog.yml` exercises the composite
action, checking multiline notes, accents, literal shell syntax, paths containing
spaces, preservation of existing releases, and updated comparison links.
