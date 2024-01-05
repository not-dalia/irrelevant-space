---
title: Debugging Jekyll plugins in VSCode
draft: true
type: guide
topics:
  - Jekyll
  - Ruby
  - VSCode
  - Debugging
subtitle: "Struggles and solutions in setting up a ruby development environment."
---


>[!warning]
> This post is outdated and needs to be updated. It is so much easier now to debug Jekyll plugins in VSCode.

When I first started developing my Jekyll plugin for this theme, I struggled with debugging the plugin code. My code was riddled with lines of `Jekyll.logger` and `puts` that I kept moving around to figure out what I was doing wrong, or what I was doing right. Looking for resources on debugging jekyll plugins didn't produce much, and it took a while to reach a configuration that worked, but I got there in the end. I thought I'd share my configuration and some of the problems I ran into, in case it can be useful for anyone else building Jekyll plugins using VSCode.

## My Jekyll Setup
At the time of writing this configuration, I was using a machine running Windows so the instructions might differ slightly if you're using something else. The machine was running:
- Jekyll (version: [[Attention Needed]])
- Ruby (version: [[Attention Needed]])
- Bundler (version: [[Attention Needed]])

## Requirements
You need to set up a few things to get the debugger working.
[[Attention Needed]] Finish writing this:
First you need Ruby extension, VSCode. Link to docs which list more requirements like the required gems. I had issues installing `debase` but it helped to update to the pre-release version with `gem install debase --pre`. See [[#Issues I faced]] for more details.

Because I'm using bundler, I had to add [[Attention Needed|what?]] to the project's `Gemfile`. (as per instruction from Ruby extension docs again).

## Issues I Faced
when installing `debase` I got the following error:
```
Installing debase 0.2.4.1 with native extensions Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
```

I have no idea what it's trying to tell me, but installing the pre-release version resolved it so that's that.

Then I wrote the next configuration
```json
{
  "name": "Debug Jekyll Site",
  "type": "Ruby",
  "request": "launch",
  "cwd": "${workspaceRoot}",
  "program": "path/to/jekyll",
  "args": [
    "serve",
  ],
  "useBundler": true,
}
```

Which failed with error `Debugger terminal error: Process failed: spawn bundle ENOENT`. This meant that bundler couldn't be found. Specifying the path with `"pathToBundler": "path/to/bundler.bat"` resolved this issue.

With bundler issues resolved, the next issue was the debugging port being used by something else. The error said `Fatal exception in DebugThread loop: Only one usage of each socket address (protocol/network address/port) is normally permitted. - bind(2) for "127.0.0.1" port 1234`. If you know what's using up the port process, then you can free it. I went for the easier route of just changing my debugger port to something else. I went for 1235.

## The Final Configuration
After fixing the above issue I set up a breakpoint in the code and ran the debugger, and it worked! This is my working configuration:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Jekyll Site",
      "type": "Ruby",
      "request": "launch",
      "cwd": "${workspaceRoot}",
      "program": "path/to/jekyll",
      "args": [
        "serve",
      ],
      "useBundler": true,
      "pathToBundler": "path/to/bundler.bat",
      "debuggerPort": "1235",
    }
  ]
}
```

To use this configuration, you will need to change `program` and `pathToBundler` to point to where jekyll and bundler are location. An easy way to find that form the command prompt is to run  `where jekyll` and `where bundler` which will return the path to where they are.
