## YAGPI (Yet Another Github-Pivotal Integration)

I did a lot of Googling and found about three dozen different ways to connect GitHub and Pivotal Tracker.  This includes very popular choices like the Pivotal Tracker GitHub webhook and Zapier.

...None of these integrations support the workflow I want, which is as follows:

* A pull request is made in a repository, where the PR either (a) has a branch with the Pivotal ID in the branch name or (b) the PR states the Pivotal ID in the description.  The story associated with that ID is then marked "Finished".
* A pull request is merged.  The story associated with the ID in that PR is then marked "Delivered".

Because many of our tasks don't involve deploying, we don't have to worry about continuous integration or any of that.

YAGPI implements that workflow.
