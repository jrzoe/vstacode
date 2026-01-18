# Using VS Code on a compute cluster via code-server

I made this repo as a resource for those who may want to use VS Code when working interactively on one of BCM's compute clusters, the MHGCP (nicknamed Taco). This tutorial is geared towards Taco's architecture, where slurm is the workload manager, but the general approach should be easily adaptable to other clusters with different workload managers. VS Code has a great extension ecosystem (e.g. GitHub Copilot), and it supports just about any language (e.g. Python, R, Julia, C++, etc) you may want to work with, either natively or with extensions. This includes syntax highlighting and tab completion for these languages, even in code notebooks like Jupyter notebooks, Quarto docs, etc. This entails running a [code-server](https://github.com/coder/code-server) instance on your compute cluster and then attaching to it from a browser on your local machine, much like you would do with a Jupyter server session. 

Running code-server on your compute cluster is different from using something like the "Remote - SSH" extension within a local VS Code client, which likely won't support some of the older OS versions found on many academic compute clusters. Instead, we will run code-server within a Singularity container, which allows us to avoid any dependency issues. Singularity will maintain your user and group permissions, so you'll be able to read and write files on Taco as you normally would.

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

Now, you can copy the bash script `../run_vsc_sing.sh` to the cluster. There are three places you need to modify:

1. Set `ipnport` to a port number of your choosing that is not currently in use. The file listing ports currently in use can be found within on Teams at MHGCP Users Group > "General" channel > "Shared" tab > ports_being_used_by_people.xlsx.

2. Mount the path(s) you want to access within your container, replacing `/your/path/here`. Likely, this will be your lab's base storage path. If the mount point is instead a subdirectory, be sure to also mount your home directory and tmp directory (can be done with the environment variables `$HOME` and `$TMPDIR`, respectively).

3. Set a password for accessing your code-server instance from a web-browser by replacing `your_password_here` with a strong password of your choosing.

After editing, you can now run the script from within your interactive job:

```bash
# bash optional if you add execute permissions to the script
bash /path/to/run_vsc_sing.sh
```
First, the script will output an `ssh` command that will enable you to tunnel into this code-server instance from your local machine. Copy the text provided for you into a terminal *on your local machine* (not Taco).

Next, Singularity will download and convert the Docker image for code-server (this may take a minute or two the first time you run it or with an update to the source image). Once this finishes, you will be able to access code-server from your local browser.

You can safely detach from the `tmux` session with `Ctrl + b`, then `d`. Your server will continue running, you can reattach to the session if needed with `tmux a -t vscode`.

### Access code-server from a local browser

Within your browser of choice on your local machine, navigate to "localhost:your_port_number_here" (replace `your_port_number_here` with the port number you specified in the script). 

### Summary and notes

General workflow is to start a `tmux` session from the head node, request an interactive job from within that session, and then run the `run_vsc_sing.sh` script from within the interactive job. Tunnel into the server from you local machine with the provided `ssh` command. 

## Using GitHub Copilot within code-server

GitHub Copilot is a very helpful LLM-based coding assistant that can help you write code faster. Unlike chatbots, this is integrated directly into your coding environment. At BCM, students and possibly some staff can get free access to GitHub Copilot Pro through [GitHub Education](https://github.com/education). GitHub Copilot Pro  provides access to better models, some of which offer unlimited usage. It's incredibly handy, so be sure to sign up if you're eligible!

Normally, GitHub Copilot can be used within a local VS Code client by installing the GitHub Copilot extension from the extension marketplace. GitHub Copliot is now open source, but it is not yet hosted on the open source marketplace used by code-server. However, there is a workaround:

1. Download the VSIX file for the GitHub Copilot Chat extension using the VS Code Marketplace API. Do this by running the following command on Taco (this will downloaded in the current working directory):
```bash
curl -L --compressed -o copilot-chat.vsix "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot-chat/latest/vspackage"
```
2. Install the VSIX file within your code-server instance. To do this, navigate to the Extensions tab, click the three-dot menu at the top, and select "Install from VSIX...". Then, navigate to the location of the VSIX file you just downloaded and select it. You will then be prompted to sign in to your GitHub account to authorize the extension. After installation, the VSIX file can be deleted.

NOTE: Sometimes, the latest release of the GitHub Copilot Chat extension may not yet be compatible with code-server. If you encounter this error, try downloading an earlier version of the extension. You can visit the [VS Code Marketplace page for GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) to get the latest version; modify the download URL with a slightly earlier version (replace `latest` in the URL with a minor version earlier). So for example, if the latest version is `0.37.(something)`, try downloading `0.36.0` instead. This would yield the following link for the `curl` command:

`https://marketplace.visualstudio.com/_apis/public/gallery/publishers/GitHub/vsextensions/copilot-chat/0.36.0/vspackage`

In case one minor version earlier still does not work, two prior minor versions certainly should. code-server releases pretty closely follow VS Code releases.