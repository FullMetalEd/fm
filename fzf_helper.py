# fm/fzf_helper.py

import os
import subprocess
import sys
import yaml
from shutil import which

def get_config_path():
    """Gets the path to the config.yml file."""
    user_config_dir = os.path.expanduser("~/.config/fm")
    user_config_path = os.path.join(user_config_dir, "config.yml")

    if os.path.exists(user_config_path):
        return user_config_path
    else:
        base_dir = os.path.dirname(os.path.abspath(__file__))
        default_config_path = os.path.join(base_dir, "config.yml")
        return default_config_path

def get_scripts_dir():
    """Gets the directory where scripts are stored."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(base_dir, "scripts")

def fuzzy_find_command(command_list, query=None):
    """
    Uses fzf to fuzzy find a command from the given list.
    Returns the selected command or None if no match or cancelled.
    """
    if not which("fzf"):
        print("Error: fzf is not installed. Please install fzf.", file=sys.stderr)
        sys.exit(1)

    config_path = get_config_path()

    try:
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: Could not find config file at {config_path}", file=sys.stderr)
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing config file: {e}", file=sys.stderr)
        sys.exit(1)

    command_list = list(config["commands"].keys())

    try:
        # Use a list comprehension to build the fzf_input string
        fzf_input = "\n".join(command_list)

        # Construct the fzf command with optional query
        fzf_command = ["fzf", "--header=Select a command:"]
        if query:
            fzf_command.append(f"--query={query}")

        # Run the fzf process
        process = subprocess.run(
            fzf_command,
            input=fzf_input,
            text=True,
            capture_output=True,
        )

        selected_command = process.stdout.strip()
        return selected_command if selected_command else None

    except FileNotFoundError:
        print("Error: fzf is not installed. Please install fzf.", file=sys.stderr)
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
            execute_script(find_script("mkd.sh"), [path])
        else:
            print(f"'{path}' looks like a file path. Use mkf?")
            execute_script(find_script("mkf.sh"), [path])

def execute_script(script_path, args):
    """Executes a script with the given arguments."""
    try:
        subprocess.run([script_path] + args, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing script: {e}", file=sys.stderr)
        sys.exit(1)