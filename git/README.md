# handy things for git

`gitinfo.sh` is a "where am I and what was I doing" script for while in 
a git working copy. An example of the output is:

```
14:51 sleak@cori10:H/modulefiles$ git info
origin	https://gitlab.nersc.gov/nersc/consulting/modulefiles.git (fetch)
origin	https://gitlab.nersc.gov/nersc/consulting/modulefiles.git (push)
Thu Jul 2 17:02:27 2020 -0700 Steve Leak 	  origin/sleak/testing-ci
* Thu Jul 2 17:02:27 2020 -0700 Steve Leak 	  sleak/testing-ci
Thu Jul 2 23:14:34 2020 +0000 Stephen Leak 	  origin/main
Thu Jul 2 23:14:34 2020 +0000 Stephen Leak 	  main
Thu Jul 2 16:10:59 2020 -0700 Steve Leak 	  origin/sleak/update-jul02
Thu Jul 2 16:10:59 2020 -0700 Steve Leak 	  sleak/update-jul02
Wed Jun 24 12:42:33 2020 -0700 Steve Leak 	  origin/sleak/update-pipeline-for-main
Wed Jun 24 12:42:33 2020 -0700 Steve Leak 	  sleak/update-pipeline-for-main
Wed Jun 24 12:29:32 2020 -0700 Steve Leak 	  origin/sleak/notes-for-consultants
Wed Jun 24 12:29:32 2020 -0700 Steve Leak 	  sleak/notes-for-consultants
Wed Jun 17 01:16:40 2020 +0000 Stephen Leak 	  origin/master
Wed Jun 17 01:16:40 2020 +0000 Stephen Leak 	  origin/HEAD
commit fad0b49f60d4ef28a43a3a3f2d5b9d5823fbd60d
Author: Steve Leak <sleak@lbl.gov>
Date:   Thu Jul 2 17:02:27 2020 -0700

    more testing

D	extra_modulefiles/dummy/README
...
local changes:
      1 ??
```

To use it I have in my `~/.gitconfig`:
```
[alias]
  info = !git_info.sh -n10 $1
  # variants to show all branches, and more detailed local status:
  longinfo = !git_info.sh
  fullinfo = !git_info.sh -f
```

