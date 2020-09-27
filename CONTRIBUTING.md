# Contributing

When contributing to this repository, select a task, feature, or issue from the [issue tab](https://github.com/StrangeRanger/linux-security-scripts/issues). If you want to add a new feature, you can create a new issue and add it to the project. The same goes for bugs.

## Planning

It's **highly recommended** to plan and discuss with the repo maintainers about any new features, to ensure that it won't interfere with other features. If this step isn't done, it could result in the rejection of the pull request because it causes conflicts or doesn't follow contribution guidelines.
  
## Coding Style

For this project, we use the coding style described [here](https://github.com/StrangeRanger/bash-style-guide).

## Commits

All commits should follow the [Conventional Commits](https://www.conventionalcommits.org) style.

All 'types' that can be used, include the following:

| Commit Type | Title                    | Description                                                                                                 |
| ----------- | ------------------------ | ----------------------------------------------------------------------------------------------------------- |
| `feat`      | Features                 | A new feature                                                                                               |
| `fix`       | Bug Fixes                | A bug Fix                                                                                                   |
| `docs`      | Documentation            | Documentation only changes                                                                                  |
| `style`     | Styles                   | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)     |
| `refactor`  | Code Refactoring         | A code change that neither fixes a bug nor adds a feature                                                   |
| `perf`      | Performance Improvements | A code change that improves performance                                                                     |
| `test`      | Tests                    | Adding missing tests or correcting existing tests                                                           |
| `build`     | Builds                   | Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)         |
| `ci`        | Continuous Integrations  | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs) |
| `chore`     | Chores                   | Other changes that don't modify src or test files                                                           |
| `revert`    | Reverts                  | Reverts a previous commit                                                                                   |

## Pull Request

1. Ensure that the code is commented and clean so that the people reviewing it or later working with it will understand what it does.
2. Update the documentation (especially the database documentation) with details of changes to the interface, including new environment variables, exposed ports, good file locations, and container parameters.
3. Clearly state why the pull request is being created by referencing the problem it's solving or the feature it's adding.
