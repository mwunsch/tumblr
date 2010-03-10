# tumblr

Ruby wrapper and command line tool for the [Tumblr API](http://www.tumblr.com/docs/en/api). In case there weren't enough of those already. This one is powered by the [Weary](http://github.com/mwunsch/weary) gem.

[RDoc](http://rdoc.info/projects/mwunsch/tumblr) | [Gem](http://rubygems.org/gems/tumblr-rb) | [Metrics](http://getcaliper.com/caliper/project?repo=git%3A%2F%2Fgithub.com%2Fmwunsch%2Ftumblr.git)

## Installation

	gem install tumblr-rb
	
## Usage

	$: tumblr path/to/a_post.markdown
	Email Address: tumblr-user@foobarmail.com
	Password:	
	Published to Tumblr. The ID for this post is: 123456789
	
You can pass `tumblr` something from standard input, but you have to set your email and password as arguments:

	$: echo 'Hello world.' | tumblr -a user@tumblr.com:supers3cretp4ssw0rd
	Published to Tumblr. The ID for this post is: 123456790
	
Try `tumblr --help` if you are in need of guidance. Read tumblr(1) for more information.

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
	
Understood YAML parameters are taken from the Tumblr API: http://www.tumblr.com/docs/en/api#api_write

Read tumblr(5) for more info.

#### All Posts

	type				regular, photo, link, quote, conversation, video, audio
						will take a guess if ommitted.
			
	state				published, queue, draft, submission
	
	format				html or markdown
	
	tags				comma-separated list of tags
	
	date    			post date
	
	private				true if the post is private
	
	slug				A custom string to appear in the post's URL
	
	group				id for a secondary blog
	
	generator			description of the publishing application
	
	send-to-twitter		Twitter status update if the tumblelog has enabled it
	
	publish-on			if the post state is 'queue', publish on this date
	
#### Additional parameters for specific Post Types

	regular			title
	
	photo			caption, click-through-url
	
	quote			source
	
	link			name, description
	
	conversation	title
	
	video			title, caption
	
	audio			caption
	
To publish to Tumblr, do this:

	request = Tumblr.new(username, password).post(document)
	request.perform do |response|
		if response.success?
			puts response.body 	# Returns the new post's id.
		else
			puts "Something went wrong: #{response.code} #{response.message}"
		end
	end

## Goals

+ Full API coverage. Leave no method behind.
+ Well tested. Like a good Rubyist.
+ Obnoxiously simple CLI. *nix idioms are wonderful.
+ Kind-of-sort-of proof-of-concept for [Weary](http://github.com/mwunsch/weary).

## TODO:

+ Tumblr::Post needs methods for liking and unliking.
+ Make the CLI
+ Make the manpages for the CLI
+ File-uploading for Photos, Videos, Audio (needs to get into Weary)

## Copyright

The Tumblr gem is Copyright (c) 2010 Mark Wunsch and is licensed under the [MIT License](http://creativecommons.org/licenses/MIT/). 

Tumblr is Copyright (c) Tumblr, Inc. The Tumblr gem is NOT affiliated with Tumblr.
