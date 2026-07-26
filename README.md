# Bash Script for Git Repository Management

## Usage

```bash
./repo_clone.sh <REPOSITORY_URL> <BRANCH_OR_TAG> <CLONE_PATH>
```

### Arguments

| Argument         | Description                                     |
| ---------------- | ----------------------------------------------- |
| `REPOSITORY_URL` | Git repository URL                              |
| `BRANCH_OR_TAG`  | Branch or tag to check out                      |
| `CLONE_PATH`     | Destination directory for the cloned repository |

### Example

```bash
./repo_clone.sh \
    https://github.com/example/project.git \
    main \
    ~/workspace/src/project
```

## Example Output

<center><img src="https://github.com/umyigit/git-clone-automation/blob/main/output.png?raw=true" alt="dockerstop gif"></center>
