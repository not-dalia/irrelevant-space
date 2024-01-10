---
type: note
title: Adding "Created At" and "Last Updated" Dates to Jekyll
---

In making the Jekyll theme I am using here, I wanted each note to show a Created At and a Last Updated date. Jekyll by default supports dates for post types. The date would be specified in the title of the post, e.g. `2020-08-01-My-Post-Title.md`. The date is then parsed by Jekyll and is available in `post.date`. Since I'm using collections instead of posts, and mainly using Obsidian to create and edit my files, my markdown files as they are being generated at the moment don't have a date in the title. I was already writing a set of plugins to add Obsidian support to Jekyll, so I thought I'd write a plugin that tells Jekyll to use the file's creation date as the post date unless it is specified in the frontmatter.

## The First (Failed) Attempt
This was simple enough. All I had to do was to add a `:documents :post_init` hook[^1] to set the `created_at` and `last_updated_at` variables to `File.ctime(doc.path)`[^2] and `File.mtime(doc.path)`[^3] respectively if they are not already set in the frontmatter. The resulting code looks something like this:

```ruby
Jekyll::Hooks.register :documents, :post_init do |doc|
  # set created at date to file creation date if not already set
  doc.data["created_at"] ||= File.ctime(doc.path)

  # set last updated date to file modification date if not already set
  doc.data["last_updated_at"] ||= File.mtime(doc.path)
end
```

This worked perfectly when I was testing it locally. But once pushed to GitHub, all the notes showed the same date, the date of when they were pushed to GitHub. What was going on?

![[ItWorksOnMyMachine.jpg|500]]
<span style="font-size: 0.9rem; text-align: center; display: block; margin-top: -1.2rem;">Source: <a href="https://simply-the-test.blogspot.com/2010/05/it-works-on-my-machine.html">It works on my machine</a></span>


### What was going on?
To understand the issue, it is important to understand the deployment setup. When a new commit gets pushed to GitHub, a GitHub action is triggered which uses [`actions/checkout@v4`](https://github.com/actions/checkout) to checkout the repo, then uses a custom action that is not relevant to this post to build the site and deploy it to GitHub Pages. When `actions/checkout@v4` checks out the repo, all the files were being created at the same time, which is the time of the checkout. This is why `File.ctime` and `File.mtime` are unsuitable for this case. What we need instead is a way to get the creation date of the file in the repo, not the creation date of the file in the local machine.

## The Second (Working) Attempt
My next plan was to use git history to set `created_at` to the file's first commit date, and the `last_updated_at` to the file's last commit date. By default, `actions/checkout@v4` checks out the repo with the `fetch-depth` option set to 1, so only the latest commit is fetched. Since I need the full git history to get the first commit date as well as the last, the GitHub actions workflow needed a small tweak:

```diff
 - name: Checkout
   uses: actions/checkout@v4
+  with:
+    fetch-depth: 0 # fetch all history for all tags and branches
```

Now that we have the full git history, we can use `git log` [^4] to get the first and last commit dates. Using `git log --follow --format=%ad --date=iso-strict -- "#{doc.path}"` we get a list of all the commit dates for the file from latest to oldest. We parse the list and assign the first and last lines to `last_updated_at` and `created_at`. A rough idea of the final code is:

```ruby
Jekyll::Hooks.register :documents, :post_init do |doc|
  git_dates_log_command = `git log --follow --format=%ad --date=iso-strict -- "#{doc.path}"`
  git_dates = git_dates_log_command.split("\n")
  doc.data["created_at"] ||= git_dates.first
  doc.data["last_updated_at"] ||= git_dates.last
end
```

> [!Warning]
> The above snippet is just a rough idea of what could work. Don't use it as it is. The next section gives some pointers on how to improve it.

## Things to Keep in Mind

### 1. Check that the dates are valid
The first and last lines of the `git log` output might not be valid dates. For example, git might output a warning or an error message instead of a date. Blindly assigning the first and last lines to `created_at` and `last_updated_at` might result in breaking the build. So it is important to check that the dates are valid and that they are actually on the first and last lines.

### 2. Allow for overriding the dates in the frontmatter
While this is a neat trick, the priority should always be given to the dates specified in the frontmatter.

### 3. To --follow or not to --follow
The `--follow` [^5] option in `git log` is used to follow the history of a file across renames. Is a renamed post a new post or an update to an existing post? That's your decision.

### 4. Avoid using timeago
After hours of trying to figure out why Jekyll was still showing "Today" for a post I modified last week, I remembered that I am using the `timeago` filter from [`jekyll-timeago`](https://github.com/markets/jekyll-timeago) plugin. I was rendering the dates using {% raw %}`{{ doc.last_modified_at | timeago }}`{% endraw %}. Now as you know Jekyll is a **static** site generator, and it renders this as HTML at the time of build, and **<u>only</u>** then. This means any date rendered with `timeago` is hardcoded as is in the HTML and won't change until the next build. I switched all the dates to the `"%-d %b %y"` format for now. Might use [`moment.js`](https://momentjs.com/) in the future to get the `timeago` dates back.

[^1]: [Jekyll Hooks](https://jekyllrb.com/docs/plugins/hooks/) are a way to run code at specific points in the Jekyll build process. The `:documents :post_init` hook runs after the documents have been read and parsed, but before it is rendered.
[^2]: [File.ctime](https://ruby-doc.org/core-2.5.1/File.html#method-c-ctime) returns the creation time of the file.
[^3]: [File.mtime](https://ruby-doc.org/core-2.5.1/File.html#method-c-mtime) returns the last modification time of the file.
[^4]: [git log](https://git-scm.com/docs/git-log) shows the commit logs.
[^5]: [git log --follow](https://git-scm.com/docs/git-log#Documentation/git-log.txt---follow) follows the history of a file across renames.
