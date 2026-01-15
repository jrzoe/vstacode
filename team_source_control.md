# Source-controlled collaboration on big data projects

Science is increasingly a team sport, now going the route of combining the expertise of multiple people to tackle a big question. Software development has long involved collaborative coding, enabled in large part by source control systems like Git and hosting platforms like GitHub. However, I find it's quite rare to see source control being used effectively, if at all, in many academic labs working within computational biology or bioinformatics. I think there are two primary reasons for this:

1. **Many trainees in academia were not formally trained in software development best practices (myself included!)**. Many people working in computational biology or bioinformatics come from a biology background and may have learned coding "on the job" without formal training. And with relatively few people using source control in academia, many don't feel the need to learn it. Fortunately, there are some exceptional resources for leaning Git, particularly [Pro Git](https://git-scm.com/book/en/v2), should git become an integral part of your lab's workflow.

2. **The data within big data projects can't be tracked within git**. Within programming, you are typically only tracking flat text files (e.g. code scripts, configuration files, etc) which are small in size and easily diffable. However, many files within computational biology or bioinformatics are massive (several GB or more) and/or binary, which are not suitable for tracking within git. If you can't track the data files in git, you need some other way to ensure the instance of the project that you're working on is the same as the one your colleague is working on. I don't know of any well-established solutions for this problem, so even those who are familiar with source control don't know a good way to approach it in the team setting when working with big data. 

Without source control, coding itself can be quite messy, but collaborative coding is even worse. I'm sure many have experienced some of the following scenarios:

* You know a colleague generated some outputs you need for an analysis, and you know generally where it's stored, but they've generated several versions of the same output file over time as they refined their code. You don't know which version is the "final" one you should be using, so you have to bug them to clarify. Alternatively, you may choose to do it yourself, leading to duplicated effort that may not even lead to the same results.
* You don't want to disturb this team member's working directory, so you copy over some files you need to your own directory. Now there are two copies of the same files (some of which may be large!), and your copy may be out of date if they make changes later on.
* Someone else wants to iterate on a script you put together while you are working on something else. They copy your script to a new location, make changes, and save it under a new name. Meanwhile, you made your own changes to fix an error and perhaps rename some things. Now there are two diverging versions, and combining them later on is a headache.

I think the following tips can enable collaborative coding that is source-controlled. These are currently suggestions based on a team working on the same compute platform.

## Project directory structure

It's helpful to use a consistent directory structure across all projects. This tip was taken from [The Good Research Code Handbook](https://goodresearch.dev/setup). A suggested structure is as follows:

```