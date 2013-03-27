# tumblr

Command line interface and Ruby client for the [Tumblr API](http://www.tumblr.com/docs/en/api/v2)

It's been rewritten from the ground up to support v2 of the api.

Like the v1, the current version reads files with a special front-matter block, like [Jekyll](http://tom.preston-werner.com/jekyll/). In addition, this new version offers the ability to post photos, videos, and audio.

Unlike the previous version, this new command line utility uses OAuth to authenticate and authorize the user.

## Installation

If you're on a Mac using [Homebrew](http://mxcl.github.com/homebrew/) and are just interested in the cli:

		brew install https://raw.github.com/mwunsch/tumblr/master/share/tumblr-rb.rb

Or with gem:

		gem install tumblr-rb

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

See [tumblr(5)](http://mwunsch.github.com/tumblr/tumblr.5.html) for more info.

## Configuration

The gem has some configuration options – API keys are kept in `~/.tumblr` and can be changed if needed. It will also use a `$TUMBLRHOST` environment variable if specified. These are usually placed in your `.bashrc` or `.zshrc`, or specified on running the `tumblr` command: `TUMBLRHOST=foo.tumblr.com tumblr post "Hello world!"`

## TODO

- [ ] Photoset support

## Copyright

The Tumblr gem is Copyright (c) 2010 - 2013 Mark Wunsch and is licensed under the [MIT License](http://creativecommons.org/licenses/MIT/).

Tumblr is Copyright (c) Tumblr, Inc. The Tumblr gem is NOT affiliated with Tumblr, Inc.
