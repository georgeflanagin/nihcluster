# README for Project Files Inventory

This document serves as an inventory of the files gathered, providing explanations of their purpose, functionality, and interrelations. Below is a breakdown organized by their respective folders and files.

---

## From Spydur

### Folders and Files:

- **`git.bash`**: Contains Git workflow utilities and macros designed for enhanced Git functionality, with specific adaptations for the University of Richmond environment.
- **`.bashrc`**: A Bash configuration file that initializes environment variables, aliases, and functions for interactive shell sessions. It includes SLURM-specific utilities and Python environment setups.

1. **shellscripts**
  - `addstudent.sh`: Automates the creation of class submission directories for students, ensuring appropriate permissions and access.
  - `bash.sh`: Configures environment variables, PATH settings, and module loading priorities for shell sessions, with additional support for Gaussian and other software.
  - `beth_jupyter.sh`: SLURM script for Beth in Dr. Mel's lab to run Jupyter Notebook.
  - `build.sh`: Sets up environment variables for PROJ library installation and compiles the project using CMake, logging the output for debugging purposes.
  - `can.sh`: Utility script to check read, write, or execute permissions on files or directories.
  - `check_active_user.sh`: Checks active users based on usage and year.
  - `checkover.sh`: Checks specific nodes for their total memory and sums memory requested.
  - `compiledeck.sh`: Automates the setup, configuration, and compilation of Quantum ESPRESSO, logging each step and managing dependencies.
  - `condafy.sh`: Initializes Anaconda3.
  - `cp.perms.sh`: Expands read and execute permissions for a list of user directories, ensuring accessibility for others.
  - `dailybackup.sh`: Backs up root and emails Carol Parish if there is a problem.
  - `detect.sh`: Checks whether the `liblzma` library used by `sshd` contains a specific function signature for potential vulnerabilities.
  - `envlist.sh`: Creates multiple Conda environments with Python 3.9 and logs their package lists.
  - `filemove.sh`: Copies a large file to a local scratch directory for temporary use and then deletes it.
  - `fixcarolsstudents.sh`: Configures user directories and permissions for Carol's students on Spydur.
  - `fixcparish.sh`: Ensures proper group ownership, permissions, and setgid settings for a list of users' directories.
  - `getfile.sh`: Provides utility functions like `whoowns`, `getfile`, and `statfile` for managing file permissions and ownership.
  - `hogs.sh`: Generates a detailed quota report for all users on the `/home` filesystem using `xfs_quota`.
  - `install_cuba.sh`: Installs or updates NVIDIA drivers and CUDA libraries with extensive system checks.
  - `install_ollama.sh`: Installs Ollama with GPU or CPU-only compatibility and dependency management.
  - `inuse.sh`: Lists managed users and displays disk usage of their home directories.
  - `jobname.sh`: Retrieves and prints all environment variables and their values in the current shell session.
  - `jupyter.py`: Automates Jupyter Notebook setup on an HPC cluster with SLURM job submission and port forwarding.
  - `jupyter.sh`: Automates the setup of Jupyter Notebook on an HPC cluster.
  - `m.sh`: Overrides the `conda` command to set `LD_LIBRARY_PATH` for `myang`.
  - `makedirpair.sh`: Creates a directory structure under the user's home directory with shared and readonly subdirectories.
  - `managed.sh`: Modifies permissions of home directories for a list of users to ensure setgid and proper access.
  - `map_zap_class.sh`: Processes genomic data using SLURM with parallelization and quality control.
  - `metabatch.sh`: Logs SLURM job submissions and monitors the pipeline with `pipereader`.
  - `ollama.sh`: Installs Ollama and GPU dependencies, ensuring system compatibility.
  - `qcinstall.sh`: Installs or updates Q-Chem with platform-specific checks.
  - `regroup.sh`: Recursively changes group ownership and permissions of directories.
  - `resetpartitions.sh`: Disables oversubscription for SLURM partitions.
  - `Rpackages.sh`: Installs R packages for spatial and ecological data analysis.
  - `saif.sh`: Creates and configures a Conda environment named "saif."
  - `slurm_completion.sh`: Provides bash completion for SLURM commands.
  - `slurm.sh`: Manages SLURM jobs by finding, suspending, or resuming them.
  - `softquotas.sh`: Sets a 10GB soft quota limit for users on the `/home` directory.
  - `spydurmap.sh`: Temporarily modifies `PYTHONPATH` to run `mapper.py`.
  - `summer2022.sh`: Deletes a project directory and copies files to multiple users' home directories.
  - `suspend_all.sh`: Suspends SLURM jobs and emails a notification of suspended job IDs.
  - `updatesubmit.sh`: Adds a `submit` command to students' `.bashrc` for file submission.
  - `usage.sh`: Generates a quota usage report for the `/home` directory.
  - `usercommands.sh`: Collects and processes `.bash_history` files for managed users.
  - `whoisin.sh`: Shows users in a named group and their last activity date.
      

2. **slurmtools**
  - `node_off.py`: This script, `node_off`, is a Python program that powers down a specified SLURM node by draining it, sending a stop signal, verifying its power status, and logging the process while handling errors and user arguments.
  - `node_on.py`: This script, `node_on`, is a Python program that powers on a specified SLURM node, verifies its status, synchronizes it if successfully powered on, and logs the process while handling errors and user arguments.
  - `nodecheck.py`: This script, `nodecheck`, is a Python program designed to monitor SLURM nodes by using `sinfo` to check their states, identifying any nodes in problematic states, and sending an email notification with the details to the HPC team if issues are detected. It also supports verbose output for detailed logging and handles user-provided arguments.
  - `nodecheck.sh`: This Bash script executes the `nodecheck.py` Python script after sourcing the `condafy.sh` script to set up the Conda environment, and then navigates to the `/usr/local/sw/slurmtools` directory where the Python script is located.
  - `parser_konstants.py`: This Python module provides common constants, regular expressions, and parsing functions for use in recursive descent parsers, supporting parsing of integers, floats, timestamps, character sequences, and other structured data formats, while leveraging the `parsec` library for functional parsing.
  - `q.json`: json file for `qq.py`
  - `qq.py`: This script, `qq`, is a command-line utility that serves as an interactive shell for managing SLURM re-queuing operations. It processes user commands, executes them using `qq_tools`, supports shell command execution and graceful exits, and handles syntax errors or interruptions.
  - `resume.sh`: This Bash script navigates to the `/usr/local/sw/slurmtools` directory, sets up the environment by updating the `PATH` and `PYTHONPATH`, extracts a numeric part from a provided node identifier by removing a prefix (`spdr`), and then runs the `node_on.py` script with the numeric node identifier as an argument.
  - `slurm.conf`: This `slurm.conf` file configures the `spydur` SLURM cluster, defining cluster details, user authentication, logging, accounting, compute nodes, and partitions with varying resources (e.g., GPUs, memory). It includes an external configuration file, `slurmplus.conf`, for additional settings.
  - `slurm.sh`: This script defines SLURM utility functions:
    - **`findscript`**: Retrieves a SLURM job's submission command.
    - **`nodepower`**: Powers nodes on or off.
    - **`readscript`**: Views and cleans up a job's submission script.
    - **`reserve`**: Reserves a node for users for a duration or until a date.
    - **`resume`**: Resumes specified nodes.
    - **`suspend`**: Suspends specified nodes.
    - **`showlog`**: Displays SLURM logs in reverse.
  - `slurm.test.conf`: This `slurm.conf` file configures the `spydur` SLURM cluster, specifying cluster details, node resources, partitions, scheduling, accounting, and power-saving settings, along with additional parameters for logging and job management.
  - `slurmparser.py`: This Python script parses SLURM node data using the `parsec` library to extract key-value pairs, making the information more machine-readable and demonstrating efficient parsing techniques.
  - `slurmplus.conf`: This configuration defines SLURM partitions for grouping nodes by purpose, sets job scheduling options, and includes placeholders for power-saving and debugging settings.
  - `slurmplus.devel.conf`: This configuration file defines SLURM settings for job scheduling, partitions, quality of service, and optional power-saving features. It organizes nodes into functional groups, includes an `onhold` partition, prioritizes jobs with multifactor scheduling, and provides placeholders for debugging and energy efficiency management.
  - `slurmplus.prod.conf`: This SLURM configuration defines partitions for organizing nodes into functional groups (e.g., `cpunodes`, `gpunodes`, `communitynodes`) with specified memory per CPU. It includes an `onhold` partition for low-priority jobs and outlines optional power-saving features, such as suspend/resume settings, to manage node activity efficiently. Debugging options and job scheduling adjustments are also provided.
  - `suspend.sh`: This script runs `node_off.py` for a specified node, setting up the environment, stripping the "spdr" prefix from the node ID, and logging execution time and errors.

3. **spydurview**
  - `Dockerfile`: This Dockerfile uses Rocky Linux 8, updates the system, installs Git and Python 3.8, clones the `activity-view` repository, and sources `activity-view.sh`. Note: only the last `FROM` is effective.
  - `info.dat`: This data lists SLURM nodes with metrics: node name, percentage (e.g., CPU usage), and a numeric value (e.g., memory or jobs).
  - `mapper.py`: This script, `mapper`, generates memory and core usage maps for SLURM nodes by parsing `sinfo` command output, scaling values for visualization, and printing the results. It utilizes structured error handling, modular scaling logic, and flexible input/output handling.
  - `scaling.py`: This script, `scaling`, generates a visual representation of resource usage as a bar (using customizable characters) by scaling `used` and `max_available` values proportionally. It provides flexible scaling, error handling, and can visualize multiple input pairs for debugging or visualization purposes.
  - `Singularity.activityview`: This Singularity file builds a `rockylinux:8` container, installs Python, Slurm client, and Git, clones the `activity-view` project, sets up an `admin` user, assigns permissions, and runs `activity-view.sh` at startup.
  - `spydurview_nologging.py`: `spydurview` is a terminal dashboard for monitoring SLURM nodes, showing core and memory usage with color-coded status (green, yellow, red) and supporting live refresh and help.
  - `spydurview.py`: Same with `spydurview_nologging.py`, but with logging
  - `spydurview.sh`: This function temporarily sets `PYTHONPATH` and clears `LD_LIBRARY_PATH` to run `spydurview.py`, then restores the original environment variables.

4. **vimstuff**
  - `dotvim`
  - `.vimrc`
  - `vimrc`


---

## From Work Station tools (wstool)

### Folders and Files:

1. **Folder1** (if applicable)
   - List of files:
     - `tool_script1.sh`: (Description to be added)
     - `tool_script2.py`: (Description to be added)
     - ...

2. **Folder2** (if applicable)
   - List of files:
     - `config1.yaml`: (Description to be added)
     - `utility_script.py`: (Description to be added)
     - ...

