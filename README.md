# tumblr

Command line interface and Ruby client for the [Tumblr API](http://www.tumblr.com/docs/en/api/v2)

It's being rewritten from the ground up to support v2 of the api.

**Check out [tag v1.3.0](https://github.com/mwunsch/tumblr/tree/v1.3.0) if you are interested in v1.** The master branch is now dedicated to v2, and is not in steady state.

Like the previous version, the current version reads files with a special front-matter block, like [Jekyll](http://tom.preston-werner.com/jekyll/). In addition, this new version offers the ability to post photos, videos, and audio.

Unlike the previous version, this new command line utility uses OAuth to authenticate and authorize the user.

## TODO

+ Documentation, documentation, documentation
+ Man pages
+ Task to build a homebrew formula

## Installation

Until the gem is published, you'll just need to clone this repository. Run `bundle install` and `bundle exec bin/tumblr`.

Alternatively, you can clone the repo, and run `rake install` -- this will build the gem, place it in the `pkg` directory, and install the gem to your system. You should then be able to `require 'tumblr'` and/or run `tumblr` from the command line.

## Authorization

Run `tumblr authorize` to boot up a small application to manage the fancy OAuth handshake with tumblr. You'll be prompted for a consumer key and secret you get from [registering an app](http://www.tumblr.com/oauth/apps).

## Getting Started

Like [Jekyll](http://tom.preston-werner.com/jekyll/), and [Mustache](http://defunkt.github.com/mustache/), Tumblr gem will transform documents preceded by a [YAML](http://www.yaml.org/) frontmatter block.

YAML frontmatter beings with `---` on a single line, followed by YAML, ending with another `---` on a single line, e.g.

	---
	type: quote
	source: Billy Shakespeare
	state: draft
	tags: hamlet, shakespeare
	---
	"To be or not to be."

Understood YAML parameters are taken from the Tumblr API: http://www.tumblr.com/docs/en/api/v2#posting

### All Posts

	type				text, photo, link, quote, chat, video, audio
						will take a guess if ommitted.

	state				published, queue, draft, private

	format				html or markdown

	tags				comma-separated list of tags

	date    			post date

	slug				A custom string to appear in the post's URL

	tweet				Manages the autotweet (if enabled) for this post

## Copyright

The Tumblr gem is Copyright (c) 2010 - 2012 Mark Wunsch and is licensed under the [MIT License](http://creativecommons.org/licenses/MIT/).

Tumblr is Copyright (c) Tumblr, Inc. The Tumblr gem is NOT affiliated with Tumblr, Inc.
