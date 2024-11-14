# README for Project Files Inventory

This document serves as an inventory of the files gathered, providing explanations of their purpose, functionality, and interrelations. Below is a breakdown organized by their respective folders and files.

---

## From Spydur

### Folders and Files:

- **git.bash**: Contains Git workflow utilities and macros designed for enhanced Git functionality, with specific adaptations for the University of Richmond environment.
- **.bashrc**: A Bash configuration file that initializes environment variables, aliases, and functions for interactive shell sessions. It includes SLURM-specific utilities and Python environment setups.

1. **shellscripts**
    - `addstudent.sh`: Automates the creation of class submission directories for students, ensuring appropriate permissions and access
    - `bash.sh`: Configures environment variables, PATH settings, and module loading priorities for shell sessions, with additional support for Gaussian and other software.
    -  `beth_jupyter.sh`: SLURM of Beth in Dr. Mel's lab to run jupyter notebook
    - `build.sh`: Sets up environment variables for PROJ library installation and compiles the project using CMake, logging the output for debugging purposes.
    - `can.sh`: A function provides a utility function to check read, write, or execute permissions on files or directories.
    - `check_active_user.sh`: A function to check active user based on usage and year
    -  `checkover.sh`: Check specific nodes about their total memory and sum memory requested
    - `compiledeck.sh`: Automates the setup, configuration, and compilation of Quantum ESPRESSO, logging each step and managing environment variables and dependencies.
    - `condafy.sh`: Initialize anaconda3
    - `cp.perms.sh`: Expands read and execute permissions for a list of user directories, ensuring accessibility for others as specified.
    - `dailybackup.sh`: Backup root and email Carol Parish if there is a problem
    -  `detect.sh`: This shell script checks whether the `liblzma` library used by `sshd` contains a specific function signature to determine potential vulnerability.
    - `envlist.sh`: The script creates multiple Conda environments with Python 3.9 and logs their package lists.
    - `filemove.sh`: The script copies a large file to a local scratch directory for temporary use and then deletes it.
    - `fixcarolsstudents.sh`: This script configures user directories and permissions for Carol's students on Spydur to ensure consistent access and group settings for their home and scratch directories.
    - `fixcparish.sh`: This script ensures proper group ownership, permissions, and setgid settings for a list of users' home and scratch directories in Spydur, maintaining consistent group access and permissions for all managed files and directories.
    - `getfile.sh`: This script provides three utility functions:
      1. **`whoowns`**: Prints the owner of a given file or directory using the `stat` command.
      2. **`getfile`**: Copies a file to the current directory, temporarily modifying permissions if the file is not readable by the user.
      3. **`statfile`**: Displays detailed information about a file, temporarily modifying directory permissions if the file is not accessible.
    - `hogs.sh`: This command uses `xfs_quota` to generate a detailed quota report for all users (`-u`) on the `/home` filesystem, including both active and inactive users (`-ah`). 
    - `install_cuba.sh`: This script is a comprehensive, interactive utility for installing and updating NVIDIA drivers and CUDA libraries on Linux systems (versions 8 or 9). It includes extensive pre-installation checks, system updates, uninstallation of existing drivers, and configuration of necessary repositories, ensuring compatibility and a clean installation.
    - `install_ollama.sh`: This shell script is an advanced installer for **Ollama** on Linux systems. It detects the system architecture, manages dependencies, and handles the installation of necessary GPU drivers (NVIDIA or AMD) and CUDA libraries, ensuring compatibility with the user's system. It also supports WSL2 environments, systemd configuration, and fallback modes for CPU-only operation if no supported GPU is detected.
    - `inuse.sh`: This script lists all users in the "managed" group, then iterates over their usernames and displays the disk usage of each user's home directory.
    - `jobname.sh`: This script retrieves and prints all environment variables and their values in the current shell session by using the `env` command.
    - `jupyter.py`: This Python script is a sophisticated utility for automating the setup of Jupyter Notebook on an HPC cluster (default is "spydur"). It performs the following key functions:
      1. **Argument Parsing**: Accepts parameters such as partition, username, runtime (hours), GPU count, and cluster name.
      2. **Environment Validation**: Validates the OS, browser, cluster partition, and required tools.
      3. **Port Allocation**: Finds open ports for setting up SSH tunnels between the local machine and the cluster head/computing nodes.
      4. **SLURM Job Submission**: Configures and submits a SLURM job to allocate resources on the cluster.
      5. **Jupyter Notebook Launch**: Starts the Jupyter Notebook server on the allocated cluster node, configures a tunnel, and generates a connection URL.
      6. **Progress Feedback**: Provides user feedback through a progress bar during the setup.
      7. **Browser Launch**: Opens the generated Jupyter Notebook URL in the default browser.
    - `jupyter.sh`: This script automates the setup of a Jupyter Notebook on an HPC cluster, including SLURM job allocation, port forwarding, and browser launch.
    - `m.sh`: This function overrides the `conda` command to set `LD_LIBRARY_PATH` for `myang`
    - `makedirpair.sh`: This script creates a directory structure under the user's home directory with a parent directory and two subdirectories: `shared` (read/write for a specified group) and `readonly` (readable by the group but writable only by the user), ensuring proper permissions and group association for collaborative use.
    - `managed.sh`: This script modifies the permissions of home directories for a list of users, setting them to **2711**. This ensures that:
      1. The **setgid** bit is set (2), so files created in these directories inherit the group of the directory.
      2. The owner has execute (1) permissions.
      3. Others have execute (1) permissions, allowing access to the directory structure but not file reading.
    - `map_zap_class.sh`: This SLURM script processes genomic data by mapping sequencing reads to a reference genome. It handles merging, trimming, mapping, sorting, and removing duplicates from reads. Quality control is integrated at multiple stages, and results are organized into directories. Parallelization is achieved using SLURM array jobs, making it efficient for large datasets. Logs track warnings and completion status throughout the pipeline.
    - `metabatch.sh`: This script overrides `sbatch` to log job submissions into a file and continuously monitors the pipeline using `pipereader`.
    - `ollama.sh`: This script detects the Linux architecture and installs the appropriate version of Ollama, along with optional GPU dependencies like NVIDIA or AMD drivers and CUDA libraries, ensuring compatibility and automation in setup.
    - `qcinstall.sh`: This script installs or updates Q-Chem with platform-specific checks, internet verification, and live updates.
    - `regroup.sh`: This script defines a `regroup` function to recursively change the group ownership and permissions of a directory and its contents.
    - `resetpartitions.sh`: This script loops through a list of partitions and disables oversubscription for each by running the `scontrol update` command as the `slurm` user.
    - `Rpackages.sh`: This script installs essential R packages for spatial and ecological data analysis.
    - `saif.sh`: This script automates the creation and configuration of a Conda environment named "saif" for installing Python dependencies and the `rl_zoo3` package.
    - `slurm_completion.sh`: This script provides bash completion for various Slurm commands, enhancing the user experience by suggesting available options, parameters, and values dynamically during command-line input.
    - `slurm.sh`: These functions help manage Slurm jobs by finding a job's script, suspending all running jobs, and resuming previously suspended jobs.
    





2. **slurmtools**
   - List of files:
     - `slurm_tool1.py`: (Description to be added)
     - `slurm_tool2.conf`: (Description to be added)
     - ...

3. **spydurview**
   - List of files:
     - `view_script1.py`: (Description to be added)
     - `view_config.yaml`: (Description to be added)
     - ...

4. **vimstuff**
   - List of files:
     - `vim_config.vim`: (Description to be added)
     - `syntax_highlighting.vim`: (Description to be added)
     - ...

---

## From Wstool

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

