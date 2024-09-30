# Credits
__author__ = 'João Tonini'
__copyright__ = 'Copyright 2024'
__credits__ = None
__version__ = '9.87'
__maintainer__ = 'George Flanagin'
__email__ = ['jtonini@richmond.edu']
__status__ = 'Research'
__license__ = 'MIT'

import os
import platform
import subprocess
import time
import shutil
import sys
from tqdm import tqdm
from datetime import datetime

######################
# Global Variables
######################
default_cluster = "spydur"  # Default cluster
created_files = ["tunnelspec.txt", "urlspec.txt", "salloc.txt", "jparams.txt"]
jupyter_exe = "/usr/local/sw/anaconda/anaconda3/bin/jupyter notebook --NotebookApp.open_browser=False"
partition = "basic"
runtime = 1
thisjob = ""
thisnode = ""
current_os = platform.system()  # Define the current operating system

# Custom print function to control displayed messages
def custom_print(message_type, cluster_name=default_cluster):
    messages = {
        "header": "This is a University of Richmond (UofR) computer system.",
        "version": f"This version of the script was updated on {datetime.fromtimestamp(os.path.getmtime(__file__)).strftime('%Y-%m-%d %H:%M:%S')}.",
        "processing": f"Your request is being processed on the {cluster_name} cluster, please wait, and a web browser will open with Jupyter..."
    }
    print(messages.get(message_type, ""))

# Function to display usage instructions if no arguments are provided
def display_usage():
    print("\nUsage: python jupyter.py <PARTITION> <USERNAME> [HOURS] [GPU] [CLUSTER]")
    print("    PARTITION  -- the name of the partition where you want your job to run (required)")
    print("    USERNAME   -- the name of the user on the cluster (required)")
    print("    HOURS      -- the runtime in hours (optional, defaults to 1, max is 8)")
    print("    GPU        -- the number of GPUs (optional, defaults to 0 or NONE)")
    print("    CLUSTER    -- the name of the cluster (optional, defaults to 'spydur')\n")

# Function to determine the default browser based on the current OS
def default_browser():
    browser_exe = os.environ.get('BROWSER')
    if not browser_exe:
        if current_os == 'Linux':
            browser_exe = subprocess.check_output(['xdg-settings', 'get', 'default-web-browser'], stderr=subprocess.DEVNULL).decode().strip()
        elif current_os == "Darwin":  # macOS
            browser_exe = "open"
        elif current_os == "Windows":
            browser_exe = "start"
        else:
            browser_exe = None
    return browser_exe

launcher = default_browser()
if not launcher:
    sys.exit("Cannot determine how to start your browser. This script is not for you.")

# Function to run shell commands
def run_command(cmd, shell=False):
    try:
        # Suppress all shell command output
        result = subprocess.run(cmd, shell=shell, check=True, text=True, capture_output=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return None

# Function to limit runtime to a maximum of 8 hours
def limit_time(runtime):
    return min(runtime, 8)

# Function to find an open port within a specified range
def open_port(name_fragment, lower=9500, upper=9600):
    if current_os == 'Linux':
        # Use 'ss' on Linux
        check_cmd = ['ss', '-tuln']
    elif current_os == 'Darwin':  # macOS
        # Use 'netstat' on macOS
        check_cmd = ['netstat', '-an']
    elif current_os == 'Windows':  # Windows
        # Use 'netstat' on Windows
        check_cmd = ['netstat', '-an']
    else:
        raise OSError("Unsupported OS for port scanning")

    for port in range(lower, upper + 1):
        result = subprocess.run(check_cmd, capture_output=True, text=True)
        if f".{port} " not in result.stdout and f":{port} " not in result.stdout:
            with open(os.path.expanduser(f"~/openport.{name_fragment}.txt"), 'w') as file:
                file.write(f"{port}")
            return port
    return None

# Function to handle port script on HPC headnode
def open_port_script(name_fragment):
    port = open_port(name_fragment)
    if port:
        run_command(['bash', 'open_port.sh'])

# Function to validate partition
def valid_partition(partition, cluster_name):
    if not partition:
        return False

    partitions = run_command(f"ssh {me}@{cluster_name} 'sinfo -o \"%P\"'", shell=True).split()
    return partition in partitions

# Function to create SLURM job and set up tunnel
def slurm_jupyter(progress_bar, cluster_name):
    # Parse the parameters from jparams.txt manually
    with open('jparams.txt', 'r') as file:
        for line in file:
            if line.startswith('export'):
                key, value = line.replace('export ', '').split('=')
                globals()[key.strip()] = value.strip()

    open_port_script('headnode')
    
    gpu = os.environ.get('gpu', 'NONE')
    partition = os.environ.get('partition')
    runtime = os.environ.get('runtime')
    
    if gpu == "NONE":
        cmd = f"salloc --account {me} -p {partition} --time={runtime}:00:00 --no-shell > salloc.txt 2>&1"
    else:
        cmd = f"salloc --account {me} -p {partition} --gpus={gpu} --time={runtime}:00:00 --no-shell > salloc.txt 2>&1"
    
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        return
    else:
        time.sleep(5)
        thisjob = subprocess.check_output("cat salloc.txt | head -1 | awk '{print $NF}'", shell=True, stderr=subprocess.DEVNULL).decode().strip()
        thisnode = subprocess.check_output(f"squeue -o %N -j {thisjob} | tail -1", shell=True, stderr=subprocess.DEVNULL).decode().strip()

    result = subprocess.run(f"ssh {me}@{thisnode} 'source {thisscript} && open_port_script computenode'", shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        return
    time.sleep(1)
    
    with open(os.path.expanduser("~/openport.computenode.txt"), 'r') as file:
        jupyter_port = file.read().strip()

    with open(os.path.expanduser("~/tunnelspec.txt"), 'w') as file:
        file.write(f"ssh -q -f -N -L {jupyter_port}:{thisnode}:{jupyter_port} {me}@{cluster_name}\n")
        file.write(f"export jupyter_port={jupyter_port}\n")

    # Update the progress bar before launching Jupyter
    progress_bar.update(2)
    time.sleep(2)  # Adding a small delay for visualization
    subprocess.run(f"ssh {me}@{thisnode} 'source /usr/local/sw/anaconda/anaconda3/bin/activate cleancondajupyter ; nohup {jupyter_exe} --ip=0.0.0.0 --port={jupyter_port} > jupyter.log 2>&1 & disown'", shell=True, capture_output=True, text=True)
    
    progress_bar.update(1)
    time.sleep(5)
    subprocess.run(f"ssh {me}@{thisnode} 'tac jupyter.log | grep -a -m 1 \"127\\.0\\.0\\.1\" > urlspec.txt'", shell=True, capture_output=True, text=True)

    progress_bar.update(1)  # Final step in tunnel setup

# Function to run the Jupyter setup
def run_jupyter(args):
    if len(args) < 2:
        display_usage()
        return

    # Display system info only if arguments are passed
    cluster_name = args[4] if len(args) > 4 else default_cluster
    custom_print("header", cluster_name)
    custom_print("version", cluster_name)
    custom_print("processing", cluster_name)

    global me
    partition, me, runtime, gpu = args[0], args[1], int(args[2]) if len(args) > 2 else 1, args[3] if len(args) > 3 else 'NONE'

    if not valid_partition(partition, cluster_name):
        return

    runtime = limit_time(runtime)
    
    with open('jparams.txt', 'w') as file:
        file.write(f"export partition={partition}\nexport me={me}\nexport runtime={runtime}\nexport gpu={gpu}\n")

    subprocess.run(f"ssh {me}@{cluster_name} 'rm -fv {created_files}'", shell=True, capture_output=True, text=True)

    shutil.copy('jparams.txt', os.path.expanduser(f"~/{me}"))
    shutil.copy(__file__, os.path.expanduser(f"~/{me}"))

    # Progress bar initialization
    progress_bar = tqdm(total=4, desc="Setting up Jupyter Tunnel")
    slurm_jupyter(progress_bar, cluster_name)
    
    if subprocess.run(f"scp {me}@{cluster_name}:~/tunnelspec.txt ~/.", shell=True, capture_output=True, text=True).returncode != 0:
        return
    
    with open(os.path.expanduser("~/tunnelspec.txt"), 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith("ssh -q"):
                subprocess.run(line, shell=True, capture_output=True, text=True)
            elif line.startswith("export"):
                key, value = line.split("=")
                os.environ[key.split()[1]] = value.strip()

    if subprocess.run(f"scp {me}@{cluster_name}:~/urlspec.txt ~/.", shell=True, capture_output=True, text=True).returncode != 0:
        return

    with open(os.path.expanduser("~/urlspec.txt"), 'r') as file:
        url = file.read().split()[-1]
    
    if not url:
        return

    progress_bar.update(1)  # Show final progress before launching the browser
    if launcher:
        subprocess.run([launcher, url], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if __name__ == "__main__":
    run_jupyter(sys.argv[1:])

