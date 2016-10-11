---
layout: post
title: "I Suck at Git"
date: 2016-10-02 21:57
comments: true
categories:
---

## No really, I **_suck_** at git.

####Give me too much rope and, well, you know...

The other day, at work, I got myself into GIT trouble. This happens once or twice a year. I'll get clever, attempt something above my git pay grade, foul things up royally, and eventually call in an expert. Often times this is Jay. In this case it was my co-worker Colin.

####What did my git fat fingers screw up?

I'm so glad you asked. Apple recently released Xcode 8. A requirement of using Swift and Xcode 8 (out of the box) is that your code must be Swift 2.3 or Swift 3.0. Up until the move to Xcode 8 Ello's iOS codebase was written in the production version of Swift, 2.2. Like a good git citizen, I created a topic branch from `master` named `sd/swift-2-dot-3`. Brilliant. No problems yet.

The conversion of over 50k lines of Swift 2.2 to Swift 2.3 ended up being a bigger task than originally planned. Not entirely surprising but we had other "real" work to do. We decided to branch off of `sd/swift-2-dot-3` for all feature work happening at the same time. For example, when adding **Awesome Widget** we'd simply `git co sd/swift-2-dot-3` followed with `git co -b sd/feature/awesome-widget`.

####No big deal

During the conversion process we needed to push a hot fix for a bug found on a version of the app that was based off of the Swift 2.2 `master` branch. We made the change, submitted a build to the AppStore and continued working on Swift 2.3 features.

####Horror

The problem came when I decided to rebase `sd/swift-2-dot-3` onto `master`. Bad Sean. I've been told by many people, Colin included, that I should not be rebasing. Ever. I like rebasing because I want my commits to come after all the vetted commits in `master`.

Folks like Colin say that rebasing is not in the spirit of git. I'm pretty sure he sent me a Linus Torvalds rant echoing the same. Spirit schmirit. Another argument for not rebasing anything public, and the one that actually matters to me, is that it can create an ungodly mess. I now agree with this wholeheartedly.

####Back to my blunder

The negative effects of my rebasing `sd/swift-2-dot-3` onto `master` were not immediately apparent. We eventually merged several pull requests into `sd/swift-2-dot-3` and planned to distribute an internal TestFlight build of the app. Before I sent it live Colin messaged me in Slack.

![Missing Commits](/assets/colin-git.jpg)

####Uh oh

I hadn't even noticed.

The issue ended up being (we think) that Github's pull requests (a GitHub feature, not a git feature) lock the base branch to merge into directly to an individual commit, not to the branch. Rebasing `sd/swift-2-dot-3` onto `master` does not change the commit that `My Awesome Pull Request` will be merged into if the pull request was created prior to the rebase. This should have been obvious but it wasn't. The pull request merge will continue to be merged into the original commit associated with the base branch, `sd/swift-2-dot-3` in this case. It will not be merged into the completely rewritten commit history of `sd/swift-2-dot-3` as it exists after the rebase. It gets merged into a commit that is no longer relevant to the rebased branch. This effectively orphans the merge.

###Moral of the story

Don't rebase anything other people are working with. Especially don't rebase a branch that has other un-merged branches off of it. You'll feel stupid and make a ton of extra work for yourself, or for Colin since he is the one who will inevitably end up fixing it for you when you stare at your screen in horror.

###How to fix it?

[`git cherry-pick`](https://git-scm.com/docs/git-cherry-pick) is your friend here. We ended up identifying each missing commit and cherry picked them (in original order) into a new branch created from `master` which had the merged `sd/swift-2-dot-3` code. Then we submitted a new [pull request](https://github.com/ello/ello-ios/pull/156) for all of the open-source world to see :).

I've fought Colin on the whole "rebase vs merge" debate for a long time. I took my licks on this one. I have a few other git-gotchas to talk about in the future. Believe it or not, this is not my first (or last) time sucking at git.