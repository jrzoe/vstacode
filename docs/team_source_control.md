# Source-controlled collaboration on big data projects

Science is increasingly a team sport, now going the route of combining the expertise of multiple people to tackle a big question. Software development has long involved collaborative coding, enabled in large part by source control systems like Git and hosting platforms like GitHub. However, I find it's quite rare to see source control being used effectively, if at all, in many academic labs working within computational biology or bioinformatics. I myself didn't start using it consistently until the start of the 4th year of my PhD, and even then not for collaborative projects. I think there are two primary reasons for this:

1. **Many trainees in academia were not formally trained in software development best practices (myself included!)**. Many people working in computational biology or bioinformatics come from a biology background and may have learned coding "on the job" without formal training. And with relatively few people using source control in academia, many don't feel the need to learn it. Fortunately, there are some exceptional resources for learning Git, particularly [Pro Git](https://git-scm.com/book/en/v2), should Git become an integral part of your or your lab's workflow (which it should!).

2. **The data within big data projects can't be tracked within git**. Within programming, you are typically only tracking flat text files (e.g. code scripts, configuration files, etc) which are small in size and easily diffable. However, many files within computational biology or bioinformatics are massive (several GB or more) and/or binary, which are not suitable for tracking within git. If you can't track the data files in git, you need some other way to ensure the instance of the project that you're working on is the same as the one your colleague is working on. I don't know of any well-established solutions for this problem, so even those who are familiar with source control don't know a good way to approach it in the team setting when working with big data. 

Without source control, coding individually can be quite messy, but collaborative coding is even worse. I'm sure many have experienced some of the following scenarios:

* You know a colleague generated some outputs you need for an analysis, and you know generally where it's stored, but they've generated several versions of the same output file over time as they refined their code. You don't know which version is the "final" one you should be using, so you have to bug them to clarify. Alternatively, you may choose to do it yourself, leading to duplicated effort that may not even lead to the same results.
* You don't want to disturb this team member's working directory, so you copy over some files you need to your own directory. Now there are two copies of the same files (some of which may be large!), and your copy may be out of date if they make changes later on.
* Someone else wants to iterate on a script you put together while you are working on something else. They copy your script to a new location, make changes, and save it under a new name. Meanwhile, you made your own changes to fix an error and perhaps rename some things. Now there are two diverging versions, and combining them requires some nontrivial effort on your end.

I think the following tips can enable collaborative coding that is source-controlled. These are currently suggestions for a team working on the same compute platform. I assume you have some basic knowledge of Git and GitHub in this discussion.

## Collaborating on a project on a shared compute platform

Please see the doc `structure_lab_dir.md` on organizing your broader lab partition and project subfolders therein. Once you have a dedicated data directory and a well-structured project directory, collaborating on code becomes pretty trivial. Let's say you've been working on the project `splicing_cell_line_a` on your own in the `projects` directory. You've been using git to track your code changes, and you've pushed your changes to a remote repository on GitHub. Now, your talented colleague Bob wants to contribute to the project.

You and Bob should both clone the remote repository from GitHub into your own personal home directories on the compute platform. The original stored in `projects/splicing_cell_line_a` will effectively serve as a local master repo for data symlinks and results (we'll see how that part works below). So to clone:

```
cd ~/  # your home directory
git clone <repository_url> ./splicing_cell_line_a
```

Now, both of you have your own copies of the code pertaining to the project. Next, you need to pull in files not tracked in git: data files and results. Symlink the `data` and `results` directories from the local master copy into your home directory copy:

```
ln -s /path/to/lab_partition/projects/splicing_cell_line_a/data ~/splicing_cell_line_a/data
ln -s /path/to/lab_partition/projects/splicing_cell_line_a/results ~/splicing_cell_line_a/results
```

Now you're both up to date on code, data, and results. Bob wants to get going on some new analyses, so he creates a new branch for his changes:

```
git checkout -b cool_new_analysis
```

For this cool new analysis, Bob realizes he needs some more input data, so he symlinks them into his working version. He puts together some code, and he generates some new results. He commits his new code (let's just assume it's in one commit here), and pushes this commit to his branch on the remote repository on GitHub:

```
git add .
git commit -m "Added cool new analysis"
git push origin cool_new_analysis
```

Now, Bob wants to share his changes with you. He creates a pull request on GitHub from his `cool_new_analysis` branch to the `main` branch. You review his code (you are the project lead), suggest some changes perhaps, and eventually approve the pull request and merge it into `main`. You can now pull the latest changes from the remote `main` to the local master, and your home directory copy if desired. Bob can do the same if he will continue working on the project. Code is all synced up!

Remember, Bob also looped in some new data and generated some new results. Because `data` and `results` directories are symlinked to the local master copy, any data symlinks or results files Bob added were actually stored in the local master copy in `projects/splicing_cell_line_a`. Data and results are now synced up as well!

That's the basic workflow. To summarize, the major steps are:
1. Each collaborator clones the remote repository into their home directory.
2. Each collaborator symlinks the `data` and `results` directories from the local master copy into their home directory copy.
3. Collaborators create branches for their changes, commit and push changes to the remote repository, and create pull requests for code review and merging. Any new data or results files are automatically synced via the symlinks.
