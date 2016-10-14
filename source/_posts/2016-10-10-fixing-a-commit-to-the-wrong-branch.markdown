---
layout: post
title: "Fixing a commit to the wrong branch"
date: 2016-10-10 22:16
comments: true
categories: git
---

In my last post [I Suck at Git](http://seancdougherty.com/blog/2016/10/02/i-suck-at-git/) I mentioned that I'd post some other git-gotchas in the future. I love this workflow, courtesy of Colin, my goto for all things git.

Have you ever made changes to files in an existing git project, committed them, and realized you intended to commit the changes to a different branch?

###I have

Here is the scenario. At Ello, we use a simple branching model. You're probably familar with it. `master` is kept clean, ideally only production ready code sees the light of `master`. When working on bug fixes or features we create topic or feature branches. A typical flow starts with a fresh pull from master.

```
git co master
git pull
```

Followed by creating a feature branch.

```
git co -b sd/feature/make-america-great-again
```

Next, all the code that Makes America Great Again is written, the tests are written, they're submitted as a pull-request, reviewed, updated, and finally submitted for acceptance testing, approved and merged.

This is the typical flow. It works great. Most of the time.

But what if someone (finger pointed at myself) gets a little ahead of himself and forgets to create a topic/feature branch? What if they write some *tremendous* code and immediately commit it directly to master?

```
git co master
git pull
... write some tremendous code
git add ... tremendous code
git commit -m "adds tremendous code"
... write more amazing code
git add ... amazing code
git commit -m "adds amazing code"
```

After realizing that there are two commits in master that I intended to commit to `sd/feature/make-america-great-again` I need to fix things. It turns out that the fix is pretty simple. There are several approaches to the problem but I really like this one.

1. create a new branch
1. checkout master
1. `git reset HEAD~` the requisite number of times
1. move on with your life

After executing the offending commits.

```
git co -b sd/feature/make-america-great-again
git co master
git reset HEAD~ // undoes the most recent commit, leaving the modified changes on disk
git reset HEAD~ // undoes the next commit, leaving the modified changes on disk
... do what you want, git stash is a reasonable idea
git co sd/feature/make-america-great-again // now you have the commits on the originally intended branch
```

Crisis overted. Thats pretty much it. You're now in the position you inteded to be in the first place. Working on a feature branch, having commited a couple of changes. No harm, no foul.
