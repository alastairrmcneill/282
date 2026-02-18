# Contributing to 282 - Munro Bagging App

Welcome to the 282 project! Thank you for considering contributing to this munro bagging app for the Scottish hiking community. 🏔️

## Quick Start

New to the project? Start here:

1. **[Setup Guide](SETUP.md)** - Get your development environment up and running
2. **[Developer Workflow Guide](DEVELOPER_WORKFLOW.md)** - Understand the project architecture and how to implement features
3. **Contributing Guidelines** (below) - Learn how to submit your contributions

## Table of Contents

1. [How to Contribute](#how-to-contribute)
2. [Git Workflow](#git-workflow)
3. [Pull Request Process](#pull-request-process)
4. [Code Review](#code-review)
5. [Documentation](#documentation)
6. [Security](#security)
7. [Getting Help](#getting-help)

## How to Contribute

There are many ways to contribute to 282:

### Reporting Bugs

If you find a bug:

1. Check [existing issues](https://github.com/alastairrmcneill/282/issues) to avoid duplicates
2. Create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Screenshots if applicable
   - Your environment (OS, Flutter version, device)
   - Relevant logs or error messages

### Suggesting Features

Have an idea for a new feature?

1. Check [existing issues](https://github.com/alastairrmcneill/282/issues) to see if it's already suggested
2. Create a new issue with:
   - Clear description of the feature
   - Why it would be useful
   - How it might work
   - Any potential challenges

### Contributing Code

Ready to write code?

1. **Find an issue** to work on (or create one)
2. **Comment on the issue** to let others know you're working on it
3. **Follow the [Setup Guide](SETUP.md)** to get your environment ready
4. **Read the [Developer Workflow Guide](DEVELOPER_WORKFLOW.md)** to understand the codebase
5. **Make your changes** following our code style guidelines
6. **Test your changes** thoroughly
7. **Submit a pull request**

## Git Workflow

### Branching Strategy

We use a simple branching strategy:

- `main` - Production-ready code
- `feature/your-feature-name` - New features
- `fix/bug-description` - Bug fixes
- `refactor/what-youre-refactoring` - Code refactoring
- `docs/what-youre-documenting` - Documentation updates

### Making Changes

1. **Fork the repository** (first-time contributors)

2. **Clone your fork**:

   ```bash
   git clone https://github.com/YOUR-USERNAME/282.git
   cd 282
   ```

3. **Create a feature branch**:

   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes** following our guidelines

5. **Commit your changes** with clear messages:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

## Pull Request Process

### Submitting Your PR

1. **Push to your fork**:

   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request** on GitHub

3. **Fill out the PR template** with:

   - Description of changes
   - Related issue number
   - Testing performed
   - Screenshots (for UI changes)
   - Any breaking changes

4. **Wait for review** - maintainers will review your PR

### PR Title Format

Use the same format as commit messages:

```
feat: Add weather forecast to munro details
fix: Resolve crash when loading empty feed
docs: Update contributing guidelines
```

## Code Review

### What to Expect

- All PRs require review before merging
- Reviewers may request changes
- Be responsive to feedback
- Discussion is encouraged!

## Documentation

Good documentation helps everyone! When contributing:

### Code Documentation

- Add inline comments for complex logic
- Document public APIs and methods
- Include examples where helpful

### README Updates

- Update documentation when adding new features
- Keep setup instructions current
- Fix outdated information you find

### Contributing to Docs

Documentation improvements are always welcome:

- Fix typos or unclear explanations
- Add examples or diagrams
- Improve organization
- Update for new versions

**Helpful Documentation:**

- [Setup Guide](SETUP.md) - Environment setup
- [Developer Workflow Guide](DEVELOPER_WORKFLOW.md) - Architecture and patterns
- README.md - Project overview

## Security

### Reporting Security Issues

**Do not** create public issues for security vulnerabilities.

Instead:

1. Email the maintainer directly (see GitHub profile)
2. Include a detailed description of the vulnerability
3. Include steps to reproduce if possible
4. Wait for a response before disclosing publicly

### Security Best Practices

When contributing:

- **Never commit** API keys, passwords, or sensitive credentials
- **Never commit** `config/dev.json` or `config/prod.json`
- **Add and test** Row Level Security policies in Supabase for new tables
- **Validate** all user input
- **Use** secure authentication methods
- **Follow** Firebase and Supabase security best practices

**Files to never commit:**

- `config/dev.json`
- `config/prod.json`
- `assets/branch-config.json`
- `ios/Runner/AppDelegate.swift`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/client_secret_*.json`

These files contain sensitive keys and are listed in `.gitignore`.

## Getting Help

Stuck? Need clarification? We're here to help! Send us a email asking questions (see GitHub profile).

## License

This project is licensed under the MIT License. By contributing, you agree that your contributions will be licensed under the same license. Please review the [LICENSE](LICENSE) file before contributing.

---

Thank you for contributing to 282! Your help makes this munro bagging app better for the Scottish hiking community. 🏔️

**Quick Links:**

- [Setup Guide](SETUP.md) - Get started with development
- [Developer Workflow Guide](DEVELOPER_WORKFLOW.md) - Understand the codebase
- [Issues](https://github.com/alastairrmcneill/282/issues) - Find something to work on
- [Pull Requests](https://github.com/alastairrmcneill/282/pulls) - See what others are working on
