---
title: Todo
type: node
draft: true
topics: ['Jekyll']
---

- ~~Fix broken links (markdown link at the moment)~~
- Make sure not to link internal links linking to the same document!!!
- ~~Fix links inside ` ``` `   ~~
- ~~Refactor the link parser~~
	- Could it be done so that the sites dont need to be looped many times, only URL/basenames/titles are mapped and then used for backlinking? Then referencing document gets the link swapped to a html tag
	- change anchor templates to anchor includes so that they're easily customisable
- handle embeds
	- embedded links
		- create \_includes/embed.html
		- pass it content/title/needed data
			- how to choose only the block of content that is relevant?
	- embedded media
		- ~~check [supported file types](https://help.obsidian.md/Advanced+topics/Accepted+file+formats)~~
		- check [supported media types](https://help.obsidian.md/Linking+notes+and+files/Embedding+files)
			- images with resizes
			- audio files
			- pdf?
- callouts
	- ~~swap callouts to includes for thematic purposes~~
	- check for callouts within codeblocks
	- style them
- add block references as IDs
	- maybe wrap the identified block with `<span id="{BLOCK_ID}"></span>`
- convert block ids to anchors
- make sure things are accessible
- ~~How does `mailto:` resolve? is it marked as external link?~~
