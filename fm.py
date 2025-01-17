import argparse
import yaml
from run_command import run_script
from fzf_helper import fuzzy_find_command, handle_path
import os

def get_config_path():
    """Gets the path to the config.yml file."""
    user_config_dir = os.path.expanduser("~/.config/fm")
    user_config_path = os.path.join(user_config_dir, "config.yml")

    if os.path.exists(user_config_path):
        return user_config_path
    else:
        # Use the environment variable if set, otherwise use default
        default_config_path = os.environ.get("FM_CONFIG_PATH", "/lib/fm/config.yml")
        return default_config_path

def get_scripts_dir():
    """Gets the directory where scripts are stored."""
    # Use the environment variable if set, otherwise use default
    return os.environ.get("FM_SCRIPTS_DIR", "")

def main():
    config_path = get_config_path()
    scripts_dir = get_scripts_dir()

    try:
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: Could not find config file at {config_path}")
        exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing config file: {e}")
        exit(1)

    parser = argparse.ArgumentParser(
        prog="fm", description="FullMetal Function Manager (fm)"
    )
    parser.add_argument(
        "-v", "--version", action="version", version="%(prog)s 0.1.0"
    )

    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")

    for command_name, command_config in config["commands"].items():
        command_parser = subparsers.add_parser(
            command_name,
            help=command_config.get("description", ""),
            add_help=False,
        )

        command_parser.add_argument(
            "-h",
            "--help",
            action="help",
            default=argparse.SUPPRESS,
            help="Show this help message and exit.",
        )

        if "args" in command_config:
            for arg in command_config["args"]:
                arg_name = arg["name"]
                kwargs = {k: v for k, v in arg.items() if k != "name"}
                command_parser.add_argument(arg_name, **kwargs)

        command_parser.set_defaults(
            func=run_script,
            script_path=os.path.join(scripts_dir, command_config["script"]),
            command_name=command_name,
        )

    first_args, remaining_args = parser.parse_known_args()

    if first_args.command:
        if first_args.command in config["commands"]:
            command_config = config["commands"][first_args.command]
            command_parser = subparsers.choices[first_args.command]
            args = command_parser.parse_args(remaining_args)
            args.command = first_args.command
            args.script_path = os.path.join(scripts_dir, command_config["script"])
            args.func = run_script

            if command_config.get("special", False):
                args.func(args)
            else:
                if not any(
                    arg
                    for arg in vars(args)
                    if arg
                    not in ["func", "script_path", "command_name", "command", "help"]
                ):
                    command_parser.print_help()
                else:
                    args.func(args)
        else:
            print(f"Unknown command: {first_args.command}")
            selected_command = fuzzy_find_command(
                list(config["commands"].keys()), first_args.command
            )
            if selected_command:
                print(f"Did you mean '{selected_command}'?")
            else:
                print("No similar commands found.")
    else:
        selected_command = fuzzy_find_command(list(config["commands"].keys()))
        if selected_command:
            command_config = config["commands"][selected_command]
            if command_config.get("special", False):
                args = argparse.Namespace(
                    command=selected_command,
                    script_path=os.path.join(scripts_dir, command_config["script"]),
                    func=run_script,
                )
                args.func(args)
            else:
                command_parser = subparsers.choices[selected_command]
                command_parser.print_help()
        else:
            parser.print_help()

if __name__ == "__main__":
    main()