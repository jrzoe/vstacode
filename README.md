# Working on Taco interactively with VS Code

## Overview

I made this repo as a resource for those who may want to use VS Code when working interactively on BCM's MHGCP, aka Taco. VS Code has a great extension ecosystem (e.g. GitHub Copilot), and it supports just about any language (e.g. Python, R, Julia, C++, etc) you may want to work with, either natively or with extensions. This includes syntax highlighting and tab completion for these languages, including in code notebooks like Jupyter notebooks, Quarto docs, etc. This entails running a [code-server](https://github.com/coder/code-server) instance on Taco and then attaching to it from a browser on your local machine, much like you would do with a Jupyter server session. 

Running code-server on Taco is different from using something like the "Remote - SSH" extension within a local VS Code client, which likely won't support some of the older OS versions found on HPC systems like Taco. Instead, we will run code-server within a Singularity container, which allows us to avoid any dependency issues. Singularity will maintain your user and group permissions, so you'll be able to read and write files on Taco as you normally would.

## Getting code-server running

### Start an interactive job

You can keep an instance of code-server running for several days with appropriate SLURM resource requests and through the use of `tmux`. First, create a `tmux` session *from the head node (h00)*. 

```bash
tmux new -s vscode # create session named "vscode"
tmux a -t vscode # attach to it
```

Then, from within this `tmux` session, request an interactive job on Taco with as you usually would. For example, to start a job with 2 CPUs and 8 GB memory for 5 days, you can run:

```bash
srun -p interactive -t 5-00:00:00 -c 2 --mem=8G --job-name vscode --pty bash
```

### Run code-server within a Singularity container

Now, you can edit the bash script `run_vsc_sing.sh`.  There are two places you need to modify:

1. Set `ipnport` to a port number of your choosing that is not currently in use. The file listing ports currently in use can be found within on Teams at MHGCP Users Group > General channel > Files tab > ports_being_used_by_people.xlsx.

2. Mount the path(s) you want to access within your container, replacing `/your/path/here`. Likely, this will be your lab's base storage path. If the mount point is instead a subdirectory, be sure to also mount your home directory and temp directory (can be done with the environment variables `$HOME` and `$TMPDIR`, respectively).

After editing, you can now run the script from within your interactive job:

```bash
# bash optional if you add execute permissions
bash /path/to/run_vsc_sing.sh
```

First, the script will output an `ssh` command that will enable you to tunnel into this code-server instance from your local machine. Copy the text provided for you into a terminal *on your local machine* (not Taco).

Next, Singularity will download and convert the Docker image for code-server (this may take a minute or two the first time you run it or with an update to the source image). Once this finishes, you will be able to access code-server from your local browser.

You can safely detach from the `tmux` session with `Ctrl + b`, then `d`. Your server will continue running, you can reattach to the session if needed with `tmux a -t vscode`.

### Access code-server from a local browser

Within your browser of choice on your local machine, navigate to "localhost:your_port_number_here" (replace `your_port_number_here` with the port number you specified in the script). 

Upon accessing for the first time, I think there's a process for setting a password, but I don't remember the details.

### Summary and notes

General workflow is to start a `tmux` session from the head node, request an interactive job from within that session, and then run the `run_vsc_sing.sh` script from within the interactive job. Tunnel into the server from you local machine with the provided `ssh` command, 

## TODO

Some things I'll add to this repo:

- Instructions for getting GitHub Copilot working within your code-server instance
- Adding aliases for tunneling command rather than copying/pasting them (helpful if the command gets lost in your terminal history).
- Helpful tips on config for code-server
- Working with R environments on Taco and within code-server

Please submit an issue or PR if you have suggestions or contributions! Hoping to make this as helpful as possible for all users.