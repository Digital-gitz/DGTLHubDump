#!/usr/bin/env python3
"""
Script to display git author info and create a GitHub repository from current directory.
Usage: python script.py <repository-name>
"""

import subprocess
import sys
import os


def run_command(cmd, capture_output=True):
    """Run a shell command and return the output."""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=capture_output,
            text=True,
            check=True
        )
        return result.stdout.strip() if capture_output else None
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        print(f"Error message: {e.stderr if e.stderr else str(e)}")
        sys.exit(1)


def get_git_author():
    """Get the current git author name and email."""
    try:
        name = run_command("git config user.name")
        email = run_command("git config user.email")
        return name, email
    except:
        return None, None


def get_gh_author():
    """Get the current GitHub authenticated user."""
    try:
        username = run_command("gh api user --jq .login")
        return username
    except:
        return None


def check_git_initialized():
    """Check if current directory is a git repository."""
    return os.path.isdir('.git')


def create_github_repo(repo_name):
    """Create a new GitHub repository and push current directory to it."""
    
    # Check if git is initialized
    if not check_git_initialized():
        print("Error: Current directory is not a git repository.")
        print("Please run 'git init' first.")
        sys.exit(1)
    
    # Check if gh CLI is installed
    try:
        run_command("gh --version")
    except:
        print("Error: GitHub CLI (gh) is not installed.")
        print("Please install it from: https://cli.github.com/")
        sys.exit(1)
    
    # Check if authenticated with gh
    try:
        run_command("gh auth status")
    except:
        print("Error: Not authenticated with GitHub CLI.")
        print("Please run 'gh auth login' first.")
        sys.exit(1)
    
    print(f"\nCreating GitHub repository: {repo_name}")
    
    # Create the repository
    run_command(f'gh repo create {repo_name} --private --source=. --remote=origin')
    
    # Check if there are any commits
    try:
        run_command("git rev-parse HEAD")
        has_commits = True
    except:
        has_commits = False
    
    # If no commits, create initial commit
    if not has_commits:
        print("\nNo commits found. Creating initial commit...")
        run_command("git add .")
        run_command('git commit -m "Initial commit"')
    
    # Push to GitHub
    print("\nPushing to GitHub...")
    run_command("git push -u origin main || git push -u origin master")
    
    print(f"\n✓ Repository '{repo_name}' created successfully!")
    
    # Get the repo URL
    repo_url = run_command("gh repo view --json url --jq .url")
    print(f"✓ Repository URL: {repo_url}")


def main():
    print("=" * 50)
    print("Git & GitHub Author Information")
    print("=" * 50)
    
    # Display git author
    git_name, git_email = get_git_author()
    if git_name and git_email:
        print(f"\nGit Author:")
        print(f"  Name:  {git_name}")
        print(f"  Email: {git_email}")
    else:
        print("\nGit Author: Not configured")
        print("  Run: git config --global user.name 'Your Name'")
        print("  Run: git config --global user.email 'your@email.com'")
    
    # Display GitHub author
    gh_username = get_gh_author()
    if gh_username:
        print(f"\nGitHub Author:")
        print(f"  Username: {gh_username}")
    else:
        print("\nGitHub Author: Not authenticated")
        print("  Run: gh auth login")
    
    print("=" * 50)
    
    # Check if repository name argument is provided
    if len(sys.argv) < 2:
        print("\nTo create a GitHub repository, run:")
        print(f"  python {sys.argv[0]} <repository-name>")
        sys.exit(0)
    
    # Create GitHub repository
    repo_name = sys.argv[1]
    create_github_repo(repo_name)


if __name__ == "__main__":
    main()