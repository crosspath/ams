# Skap — document management system

Word "skap" is a variation of Germanic words "skab"/"schap"/"schaf".
Here it means storage closet with documents or books.

Skap manages local copy of source documents published in git repositories.
You may use Skap to track changes in source documents and to store revisions (versions)
of your works based on these source documents, for example abstracts.

## Available commands

```plain
help
--help
-h
    Show help message about supported commands.

init
init DIRECTORY_PATH
    Create configuration files in current directory or in DIRECTORY_PATH.

sources
    add DIRECTORY REPO BRANCH
        Add git submodule into DIRECTORY from REPO and track BRANCH by default.
    delete DIRECTORY
        Delete git submodule from DIRECTORY.
    update
    update DIRECTORY ...
        Update git submodule from upstream in DIRECTORY or in all git submodules if DIRECTORY is not
        specified. You may pass one or more directory paths (DIRECTORY ...) to update their
        contents.

version
--version
-v
    Show program version

works
    covered
    covered DIRECTORY ...
        List files of sources which have been used for published works. Pass one or more directory
        paths (DIRECTORY ...) to show files only in these directories.
    ignored
    ignored DIRECTORY ...
        List ignored files. Pass one or more directory paths (DIRECTORY ...) to show files only in
        these directories.
    outdated
    outdated DIRECTORY ...
        List documents which may contain outdated information. Pass one or more directory paths
        (DIRECTORY ...) to show files only in these directories.
    publish DOCUMENT
    publish DOCUMENT FILE_PATH ...
        Save record about work (DOCUMENT) and pass list of file paths of sources (FILE_PATH ...)
        which relate to this work. You should prepend minus sign to file path to exclude it from
        list of related sources. Examples:
        works publish _/docker/compose.md docs.docker.com/content/manuals/compose/**/*.md
        works publish _/docker/compose.md -docs.docker.com/**/*.md
    uncovered
    uncovered DIRECTORY ...
        List files of sources which have NOT been used for published works. Pass one or more
        directory paths (DIRECTORY ...) to show files only in these directories.
    unknown
    unknown DIRECTORY ...
        List files of sources which may be used for works or ignored. Pass one or more directory
        paths (DIRECTORY ...) to show files only in these directories.
```

Examples:

```shell
skap help
skap init
skap sources add docker https://github.com/docker/docs.git main
skap works unknown
```

## Suggested workflow

1. Install Skap: `gem install skap`
2. Initialize storage: `skap init ~/docs` (pass any path to storage)
3. Add sources: `skap sources add docker https://github.com/docker/docs.git main`
  (see command description in "Available commands")
4. Look into downloaded source files and fill entries in file "sources.yaml" in your storage.
5. Create file with your text (here it's known as "work") that relates somehow to source documents.
6. Save revision of source documents with current state of "work":
  `skap works publish _/docker/overview.md docker/content/get-started/docker-overview.md`
  (here "_/docker/overview.md" is path to your "work")
7. Commit changes into current git repository in your storage: `git commit ...` (see manual for git)

Additionally you may push your changes into remote repository — see manual for git:
git remote, git push.

## Additional files in storage

You should store changes in these files with "git commit".

Schema of file "sources.yaml":

```yaml
%directory-name%:
  file-extensions: [%ext%, %ext%]
  ignored:
    - %file-path-pattern-in-this-directory%
  indexed:
    - %file-path-pattern-in-this-directory%
```

Example of file "sources.yaml":

```yaml
docker:
  file-extensions: [md, yaml]
  ignored:
    - "*.md"
    - compose.yaml
  indexed:
    - content/get-started/**/*.md
```

Schema of file "versions.yaml":

```yaml
%work-file-path%:
  date: %iso-date%
  sources:
    %source-file-path%:
      date: %iso-date%
      sha: %commit-sha%
```

Example of file "versions.yaml":

```yaml
_/docker/overview.md:
  date: 2024-12-31
  sources:
    docker/content/get-started/docker-overview.md:
      date: 2024-12-31
      sha: fc77b05ffe69070796a6a8630802e62b75304455
```

## Development

Do it once — authorize on [rubygems](https://rubygems.org/) and then:

```shell
gem signin
```

Before release — apply suggestions from RuboCop, review them and commit or reject:

```shell
bin/rubocop -A --only Style/FrozenStringLiteralComment,Layout/EmptyLineAfterMagicComment
bin/rubocop -a
```

Build `*.gem` file:

```shell
bin/build
```

Push gem file to rubygems registry and then send new version to github repository:

```shell
bin/release
```
