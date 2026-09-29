# Developer Toolbox

A personal CLI toolbox for storing, searching, editing, reviewing, and executing frequently used developer commands.

The goal of this project is to replace scattered command snippets in Notepad or text files with a structured, searchable, Git-based command library that works across Windows, Git Bash, WSL, and Linux.

---

## Features

* 🔎 Fuzzy search using `fzf`
* 📂 Organize commands by category
* 👀 Preview command details before execution
* 🧩 Support command parameters
* ✏️ Edit commands before execution
* ⚠️ Detect potentially dangerous commands
* 📜 Keep a local execution history
* 💾 Save modified commands as new commands
* 🩺 Environment diagnostics with `dev doctor`
* 🔄 Git-based synchronization with `dev sync`
* 🌐 Synchronize the toolbox between Windows and Linux/WSL
* 📝 Store commands as simple Markdown files
* 🔧 Support command templates with parameters and default values

---

## Requirements

The toolbox requires:

* Bash
* Git
* `fzf`
* VS Code or another configured editor

### Windows

Recommended environment:

* Git Bash
* Windows Git
* `fzf`
* Visual Studio Code

### Linux / WSL

Required:

```bash
bash
git
fzf
```

If `fzf` is not available as `fzf`, the toolbox can also use `fzf.exe` when running in WSL with the Windows installation available.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/SadeghBashiri/developer-toolbox.git
```

Enter the project directory:

```bash
cd developer-toolbox
```

Make the main executable available:

```bash
chmod +x bin/dev
```

Run the environment diagnostic:

```bash
./bin/dev doctor
```

If everything is configured correctly, you should see:

```text
Environment is ready.
```

---

## Basic Usage

### Open the command selector

```bash
./bin/dev
```

This opens an interactive fuzzy-search interface using `fzf`.

You can search through all stored commands and preview the selected command.

---

### Run a command

```bash
./bin/dev run docker/ps
```

The command is loaded from the corresponding Markdown file.

For example:

```text
commands/docker/ps.md
```

---

### Search commands

```bash
./bin/dev search docker
```

or:

```bash
./bin/dev search logs
```

---

### List all commands

```bash
./bin/dev list
```

---

### List commands by category

```bash
./bin/dev category docker
```

Example output:

```text
docker/exec.md
docker/logs.md
docker/ps.md
```

---

### Command history

View previously executed commands:

```bash
./bin/dev history
```

The history is stored locally and is intentionally excluded from Git.

History location:

```text
.developer-toolbox-history/history.log
```

---

### Add a new command

```bash
./bin/dev add
```

The interactive wizard allows you to define:

* Category
* Command name
* Description
* Tags
* Command template
* Parameters

A new command is stored as a Markdown file under `commands/`.

---

### Environment diagnostics

Run:

```bash
./bin/dev doctor
```

The diagnostic checks:

* Bash
* Git
* fzf
* Editor
* Commands directory
* Scripts directory
* Git repository
* Git remote
* Git line-ending configuration

---

### Synchronize with GitHub

```bash
./bin/dev sync
```

The sync operation:

1. Verifies that the toolbox is a Git repository.
2. Verifies that `origin` exists.
3. Checks for uncommitted local changes.
4. Executes:

```bash
git pull --ff-only
```

5. Refuses to automatically merge conflicting changes.

The sync operation is intentionally conservative. It does **not** automatically:

* Commit changes
* Push changes
* Stash changes
* Overwrite local modifications
* Perform automatic merges

If local changes exist, commit or stash them first.

---

# Command Format

Commands are stored as Markdown files.

Example:

```text
commands/docker/logs.md
```

```markdown
NAME: docker logs
DESCRIPTION: نمایش لاگ‌های یک Docker container
TAGS: docker, container, logs

COMMAND:
docker logs {container} --tail {tail}
```

The toolbox extracts the metadata and command template from this file.

---

## Parameters

Parameters are represented using curly braces:

```text
{container}
```

When the command is executed, the toolbox asks for the parameter value.

Example:

```text
Enter value for 'container':
```

### Default values

Parameters can also define default values:

```text
{tail=100}
```

The toolbox will ask:

```text
Enter value for 'tail' [100]:
```

Pressing Enter uses the default value.

---

## Editing Before Execution

The toolbox supports editing the resolved command before execution.

For example, a template:

```bash
docker logs {container} --tail {tail}
```

can become:

```bash
docker logs kafka --tail 200
```

After parameter resolution, you can choose:

```text
Edit command before execution? [y/N]:
```

If you choose `y`, the command opens in the configured editor.

The editor is configured through:

```bash
DEV_EDITOR
```

For example:

```bash
export DEV_EDITOR=code
```

---

# Safety

The toolbox contains a basic dangerous-command detector.

Commands containing potentially destructive operations are detected before execution.

Examples include:

```text
rm -rf
mkfs
dd ... if=
shutdown
reboot
docker system prune
docker rm
docker rmi
```

Detected commands display:

* Severity
* Reason
* Full command

Example:

```text
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
WARNING: Potentially dangerous command
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Severity:

  HIGH

Reason:

  Docker container removal command detected.

Command:

  docker rm kafka
```

The toolbox does not automatically block these commands.

The final execution decision remains with the user.

---

# Project Structure

```text
developer-toolbox/
│
├── README.md
├── .gitignore
├── .gitattributes
│
├── bin/
│   └── dev
│
├── commands/
│   ├── docker/
│   ├── git/
│   ├── java/
│   ├── kafka/
│   ├── linux/
│   ├── maven/
│   ├── quarkus/
│   └── shell/
│
├── scripts/
│   ├── docker/
│   ├── git/
│   ├── kafka/
│   ├── linux/
│   └── preview-command.sh
│
├── lib/
│   ├── config.sh
│   ├── doctor.sh
│   ├── editor.sh
│   ├── executor.sh
│   ├── finder.sh
│   ├── history.sh
│   ├── parameters.sh
│   ├── parser.sh
│   ├── saver.sh
│   ├── security.sh
│   ├── sync.sh
│   └── ui.sh
│
└── docs/
```

---

# Architecture

The main execution flow is:

```text
                    ┌─────────────────┐
                    │    ./bin/dev    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Command Finder  │
                    │      + fzf      │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Command Parser  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Parameters    │
                    │    Resolver     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Command Editor  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Security Check  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Executor     │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │     History     │
                    └─────────────────┘
```

---

# Git Synchronization

The command library is stored in Git so it can be synchronized across multiple environments.

Example workflow:

```text
Windows / Git Bash
        │
        │ git push
        ▼
      GitHub
        │
        │ dev sync
        ▼
    WSL / Linux
```

This allows the same command library to be used from different development environments.

The toolbox intentionally keeps execution history local:

```text
.developer-toolbox-history/
```

This prevents machine-specific command history from being synchronized through Git.

---

# Line Endings

The project uses **LF** line endings to keep shell scripts and Markdown files consistent across Windows, WSL, and Linux.

`.gitattributes` contains:

```gitattributes
*.sh text eol=lf
bin/dev text eol=lf
*.md text eol=lf
```

Git configuration used by the repository:

```bash
git config --local core.autocrlf false
git config --local core.eol lf
```

You can verify the environment with:

```bash
./bin/dev doctor
```

---

# Development Workflow

When adding or modifying commands:

```text
1. Add / modify command
        ↓
2. Test command locally
        ↓
3. ./bin/dev doctor
        ↓
4. git status
        ↓
5. git add
        ↓
6. git commit
        ↓
7. git push
```

On another machine:

```text
1. ./bin/dev doctor
        ↓
2. ./bin/dev sync
        ↓
3. Test updated commands
```

---

# Design Principles

The project follows several principles:

### Simple storage

Commands are plain Markdown files rather than being stored in a database.

### Git-friendly

Everything important is text-based and can be version-controlled and synchronized.

### Cross-platform

The toolbox is designed to work with:

* Windows + Git Bash
* Windows + WSL
* Linux

### Human-controlled execution

The toolbox helps find, prepare, review, and execute commands, but execution remains explicitly controlled by the user.

### Safe synchronization

Synchronization uses:

```bash
git pull --ff-only
```

to avoid automatic merge commits or silent conflict resolution.

### Extensible architecture

Functionality is separated into small Bash modules:

```text
finder
parser
parameters
editor
security
executor
history
saver
doctor
sync
```

This makes it possible to add future features without turning `bin/dev` into a monolithic script.

---

# Planned Features

Possible future improvements include:

* Command aliases
* Better command categorization
* Command favorites
* Tags-based filtering
* Command usage statistics
* Improved security analysis
* Secret detection in commands
* Better history filtering
* Export/import
* Git commit/publish workflow
* Automatic command documentation
* Obsidian integration
* Command dependencies
* Interactive command chaining
* Multi-command workflows
* Shell-specific command handling
* Linux/Windows compatibility detection

---

# License

Personal project. No public license has been defined yet.

```
```
