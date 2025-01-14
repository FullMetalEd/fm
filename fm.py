import argparse
import os
import re
import subprocess
import sys
from shutil import which

def get_scripts_dir():
    """Gets the directory where scripts are stored."""
    return os.environ.get("FM_SCRIPTS_DIR", os.path.expanduser("~/.fm/scripts/"))

def find_script(script_name=None):
    """
    Finds the script by name.
    - If no script_name is provided, uses fzf to list all scripts.
    - If script_name is provided, searches for it directly.
    - Uses fzf for fuzzy finding if no exact match is found and a script name is given.
    """
    scripts_dir = get_scripts_dir()

    if not which("fzf"):
        print("Error: fzf is not installed. Please install fzf.", file=sys.stderr)
        sys.exit(1)

    if script_name is None:
        # No script name provided, list all scripts with fzf
        try:
            process = subprocess.run(
                ["fzf", "--header=Select a script to view its help:"],
                input="\n".join(
                    f for f in os.listdir(scripts_dir) 
                    if os.path.isfile(os.path.join(scripts_dir, f)) and os.access(os.path.join(scripts_dir, f), os.X_OK)
                ),
                text=True,
                capture_output=True,
                cwd=scripts_dir
            )
            selected_script = process.stdout.strip()
            if selected_script:
                return os.path.join(scripts_dir, selected_script)
            else:
                return None  # User cancelled
        except FileNotFoundError:
            print("Error: fzf is not installed. Please install fzf.", file=sys.stderr)
            sys.exit(1)

    # Script name was provided
    script_path = os.path.join(scripts_dir, script_name)
    if os.path.isfile(script_path):
        return script_path

    # Fuzzy find with fzf if no exact match
    scripts = [f for f in os.listdir(scripts_dir) if os.path.isfile(os.path.join(scripts_dir, f)) and os.access(os.path.join(scripts_dir, f), os.X_OK)]
    try:
        process = subprocess.run(
            ["fzf"],
            input="\n".join(scripts),
            text=True,
            capture_output=True,
            cwd=scripts_dir
        )
        selected_script = process.stdout.strip()
        if selected_script:
            return os.path.join(scripts_dir, selected_script)
        else:
            print(f"No matching script found for '{script_name}'.", file=sys.stderr)
            return None
    except FileNotFoundError:
        print("Error: fzf is not installed. Please install fzf.", file=sys.stderr)
        sys.exit(1)

def extract_help(script_path):
    """Extracts help information from a script."""
    help_text = ""
    with open(script_path, "r") as f:
        lines = f.readlines()
        in_help_section = False
        for line in lines:
            if line.strip() == "# ---":
                if in_help_section:
                    break
                in_help_section = True
            elif in_help_section:
                help_text += line[2:]  # Remove leading '# '
    return help_text

def execute_script(script_path, args):
    """Executes a script with the given arguments."""
    try:
        subprocess.run([script_path] + args, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing script: {e}", file=sys.stderr)
        sys.exit(1)

def handle_path(path):
    """Handles 'smart' input when a path is given."""
    if os.path.exists(path):
        if os.path.isdir(path):
            print(f"'{path}' is a directory. Default to ls, or add additional actions?")
        else:
            print(f"'{path}' is a file. Default to opening in an editor")
    else:
        if path.endswith("/"):
            print(f"'{path}' looks like a directory path. Use mkdir?")
            execute_script(find_script("mkdir"), [path])
        else:
            print(f"'{path}' looks like a file path. Use mkf?")
            execute_script(find_script("mkf"), [path])

def main():
    parser = argparse.ArgumentParser(prog="fm", description="Function/File Manager")
    parser.add_argument("command", nargs="?", help="Script name or a path")
    parser.add_argument("args", nargs="*", help="Arguments for the script")

    args = parser.parse_args()

    if args.command is None:
        # No command provided, use fzf to list scripts and show help for selected script
        script_path = find_script()
        if script_path:
            help_text = extract_help(script_path)
            if help_text:
                print(help_text)
            else:
                print(f"No help information found for '{os.path.basename(script_path)}'", file=sys.stderr)
        sys.exit(0)

    # Handle regular commands and paths
    script_path = find_script(args.command)

    if script_path:
        if args.args:
            execute_script(script_path, args.args)
        else:
            help_text = extract_help(script_path)
            if help_text:
                print(help_text)
            else:
                print(f"No help information found for '{args.command}'", file=sys.stderr)
    else:
        if os.sep in args.command or args.command.endswith("/"):
            handle_path(args.command)
        else:
            print(f"Script or path not found: {args.command}", file=sys.stderr)

if __name__ == "__main__":
    main()