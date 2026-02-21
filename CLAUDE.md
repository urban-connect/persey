# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Persey is a pure Ruby gem providing a configuration DSL with environment inheritance. No external dependencies. Requires Ruby >= 3.0.

## Commands

```bash
bundle install          # Install dependencies
bundle exec rspec       # Run all specs
bundle exec rspec spec/persey/node_spec.rb        # Run a single spec file
bundle exec rspec spec/persey/node_spec.rb:10     # Run a specific example by line
bundle exec standardrb            # Lint (Standard Ruby)
bundle exec standardrb --fix      # Lint and auto-fix
```

## Architecture

Four classes in `lib/persey/`:

- **Persey** (`persey.rb`) — Entry point. `Persey.init(env, &block)` builds config, `Persey.config` returns it, `Persey.reset!` clears state.
- **Builder** (`builder.rb`) — Evaluates the DSL block. Collects `env` definitions, resolves `parent:` inheritance chains, and deep-merges nested hashes to produce the final config hash for the selected environment.
- **Proxy** (`proxy.rb`) — Captures DSL method calls via `method_missing` into a plain hash. Nested blocks create nested Proxy instances.
- **Node** (`node.rb`) — Wraps the final config hash. Defines singleton methods for each key so config values are accessed as methods (`config.database.host`). Lambdas are evaluated in the context of the root node. Nested hashes become nested Nodes. `method_missing` on non-root nodes delegates to the root.

**Data flow:** DSL block → Builder (uses Proxy to capture each env block) → deep-merges with parent envs → wraps result in Node → returned by `Persey.config`.

## Git & PR Workflow

- Keep branch names short but readable
- Do not add Claude as a co-author to commit messages and PR descriptions
- Provide short description for the PR, do not add test cases there
- Always assign the PR to its author when creating it
- Never force push (`git push --force` / `git push -f`) branches to GitHub
- To resolve conflicts with main, use `git pull origin main` instead of `git rebase` (rebase requires force push)
- Always ask before using `--admin` flag when merging PRs — it bypasses branch protection checks

## Coding Conventions

- Always start every new file with `# frozen_string_literal: true`
- Always remove previously added but now unused code
- Follow `standard-rb` conventions — run `bundle exec standardrb --fix` for all Ruby files (including specs) you create or update before committing
- Don't over-abstract — prefer inline code over premature extraction into helpers/services
- Do not use `class << self` — define class methods with `self.method_name` instead
- Always use `private def method_name` / `protected def method_name` inline — do not place a standalone `private` or `protected` keyword above methods
- Each module should have its own folder, each class should be defined in a dedicated file

## Releasing

1. Update version in `persey.gemspec`
2. `git commit -am "Bump version to x.y.z"`
3. `git tag vx.y.z`
4. `git push origin main --tags`
5. Update `tag:` in consuming app's Gemfile
