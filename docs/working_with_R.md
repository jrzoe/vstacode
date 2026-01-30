# Working with R in code-server

Particularly when working with R on HPCs, I think many users choose to use a system-level R installaton (either on a user's PATH environment variable by default, or added through a module system). As a consequence of running code-server within a container, such an R installation won't be available in your PATH environment variable by default, nor will the module system be available to you. Fortunately, only a few tweaks are needed. I will first describe what I think is a much better workflow for using R in code-server (and more generally) via micromamba (a lightweight conda), and then describe how to continue using a system-level R installation should you wish to do so.

## Why micromamba for R?

The R package manager is quite nice for installing R packages from CRAN and Bioconductor, which may make something like micromamba seem unncessary. However, micromamba still has two significant advantages:

1. micromamba makes it trivial to install R packages with specific system-level dependencies. When working on a HPC, your system is almost certainly running on an older version of Linux, meaning that system-level libraries are out of date and incompatible with some package releases. You won't be able to alter such system-level libraries through updates on a HPC, as you don't have `sudo` access. This can make installing R packages that depend on more recent versions of system libraries a nightmare, requiring manual installations with some complex PATH editing or symlinks. With micromamba, you can simply specify a R package and any system-level dependencies will be automatically installed into your micromamba environment. 
2. micromamba makes it easy to manage multiple R installations, all with different package versions should you need them. It's good practice to provide reproducible environments for your R projects, with the specific versions of R and R pacakges used recorded so others (or even yourself down the road) can run your code without it breaking. Languages and the packages built on them change, deprecating functions or adding new ones, so code that ran fine 2 years ago might not run with modern releases of the same language or package. With micromamba, you can create a new environment for each project, with the specific versions of R and R packages you need, and switch between them easily.

Both of the above are advantages of conda as well, and the prior speed gap between conda and mamba has closed with conda's adoption of the faster [libmamba solver](https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community) used by mamba/micromamba. However, I still prefer using micromamba over conda. micromamba has the advantage of being a single binary executable. This means no more accidentially breaking your entire conda installation by accidentally messing with the `base` environment. Plus, all of your conda pacakges made by you and others are still compatible, so the cost of switching is very low.

## Setting up an R environment

I often have one micromamba environment that I use for R work in general (before a project coalesces enough to warrant its own environment). Let's say you want to set up something similar to use within code-server. (*This first step doesn't need to be done within code-server, but can be*). [Install micromamba](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html), then create an environment with R and some common packages:

```bash
micromamba create -n r-env r-base r-tidyverse r-data.table r-languageserver r-httpgd
```

Of note, the last two packages (`r-languageserver` and `r-httpgd`) are needed for features in the R extension, which will be discussed below.

*All steps from here on will be done within your Singularity container running code-server*. 

Because Singularity will source your `.bashrc` on startup, `micromamba` will be ready to go whenever you start code-server. Open a terminal and activate your new environment. 

To get some nice features like R syntax highlighting, environment monitoring, and plot viewing in code-server, you need to install an extension and do some light configuration:

1. From the "Extensions" tab in code-server, install the [R Extension](https://marketplace.visualstudio.com/items?itemName=REditorSupport.r). This is what provides many helpful features like syntax highlighting, environment monitoring, and plot viewing.
2. Edit some settings for use with this extension. The following can be pasted into your `settings.json` (editing paths if necessary), accessible from the command pane (key F1) and typing "Preferences: Open User Settings (JSON)". You can also edit these in the settings GUI if you prefer, the JSON was just easier to share here.
    ```json
    {
        "r.rpath.linux": "${userHome}/micromamba/envs/r-env/bin/R",
        "r.libPaths": [
            "${userHome}/micromamba/envs/r-env/lib/R/library"
        ],
        "r.alwaysUseActiveTerminal": true,
        "r.plot.useHttpgd": true,
    }
    ```
    Some explanation of these settings:
    - `r.rpath.linux`: This tells the R extension where to find an R executable to use for background processes like linting, pulling package information, etc. It won't actually be used for executing your code, so this doesn't need to change when you switch micromamba environments. You can change the path above to point to any micromamba environment you like, and it can remain constant.
    - `r.libPaths`: This tells R where to look for installed R packages when pulling up package information in the R extension. This should at least include the path for the environment entered above. However, if you are working on another project that has packages not included in the one above, you will need to add it to the list here as well. These paths don't need to be removed or changes when switching micromamba environments, as R will only look in the specified paths for packages when needed.
    - `r.alwaysUseActiveTerminal`: This setting makes it so that when you run R code from the editor, it will always run in the currently active terminal. This is important, as it means that if you activate a micromamba environment in a terminal, any R code you run from the editor will use that environment rather than the static path provided above.
    - `r.plot.useHttpgd`: This setting enables the use of the `httpgd` package for rendering plots within code-server, which works a bit better than the default method.

### Optional

Rather than use the base R REPL, a much nicer alternative is `radian`. This provides syntax highlighting and autocompletion in the terminal itself. It also allows you to send highlighted chunks of code (with multiple commands) to the REPL rather than having to send individual commands manually. You simply have to install it in your micromamba environment, then use `radian` instead of `R` to start the REPL.

To enable sending chunks of code to the REPL from the editor, you will also need to add the following setting to your `settings.json`:

```json
{
    "r.bracketedPaste": true,
}
``` 

## Using several R environments

So, when working with multiple R envioronments, you activate the desired micromamba environment in a terminal before running any R code. Code can be sent to the REPL (with <kbd>Cmd</kbd> + <kbd>Enter</kbd>) or run as a script from the command line. Very easy!

As mentioned above, you may need to add the library paths for each micromamba environment you use to the `r.libPaths` setting in order for the R extension to find the packages installed in those environments. However, this only needs to be done once, and you can leave all of the paths in there permanently. They will only be used to pull up package information when calling `help()`, for example.