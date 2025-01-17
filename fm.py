import yaml
import subprocess
import argparse
import os

def load_config(config_file="config.yml"):
    """Loads the configuration from the YAML file."""
    with open(config_file, "r") as f:
        return yaml.safe_load(f)

def run_script(script_path, args):
    """Runs the specified script with the given arguments."""
    try:
        # Construct the command with the script path and arguments
        command = [script_path] + args
        
        # Run the command and capture output
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()

        # Decode output (if needed)
        if stdout:
            print("Output:")
            print(stdout.decode())
        if stderr:
            print("Error:")
            print(stderr.decode())

        return process.returncode  # Return the exit code of the script

    except FileNotFoundError:
        print(f"Error: Script not found at {script_path}")
        return -1
    except Exception as e:
        print(f"An error occurred: {e}")
        return -1

def main():
    """Parses command-line arguments and runs the appropriate script."""
    config = load_config()

    parser = argparse.ArgumentParser(description="Run scripts defined in config.yml.")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Create sub-parsers for each script
    for script_name, script_data in config["scripts"].items():
        script_parser = subparsers.add_parser(script_name, help=script_data["description"])
        for arg in script_data.get("args", []):
            script_parser.add_argument(
                f"--{arg['name']}",
                help=arg["description"],
                required=arg["required"]
            )

    args = parser.parse_args()

    if args.command:
        script_data = config["script"][args.command]
        script_path = script_data["path"]
        
        # Make sure the script exists
        if not os.path.exists(script_path):
            print(f"Error: Script not found at {script_path}")
            return

        # Gather arguments for the script
        script_args = []
        for arg_data in script_data.get("args", []):
            arg_value = getattr(args, arg_data["name"])
            if arg_value is not None:
                script_args.append(str(arg_value))

        # Run the script
        exit_code = run_script(script_path, script_args)
        if exit_code == 0:
          print(f"Script {script_name} executed successfully.")
        else:
          print(f"Script {script_name} failed with exit code {exit_code}.")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()