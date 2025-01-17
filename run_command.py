# fm/run_command.py
import subprocess
import os

def run_script(args):
    """
    Runs the specified script with the given arguments.
    """
    base_dir = os.path.dirname(os.path.abspath(__file__))
    script_path = os.path.join(base_dir, "scripts", args.script_path)

    if not os.path.exists(script_path):
        print(f"Error: Script not found: {script_path}")
        return

    command = [script_path]

    # Construct the command-line arguments for the script
    for arg_name, arg_value in vars(args).items():
        if arg_name not in ["command", "func", "script_path", "command_name"]:
            if isinstance(arg_value, bool) and arg_value:
                command.append(arg_name)
            elif not isinstance(arg_value, bool):
                command.append(arg_name)
                command.append(str(arg_value))

    print(f"Running: {' '.join(command)}")
    try:
        process = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            cwd=os.path.dirname(script_path),
        )
        print(process.stdout)
        if process.returncode != 0:
            print(f"Error: Script exited with code {process.returncode}")
            print(process.stderr)

    except FileNotFoundError:
        print(f"Error: Could not find executable: {command[0]}")
    except OSError as e:
        print(f"OS Error: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")