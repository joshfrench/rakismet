Rakismet
========

**Akismet** (<http://akismet.com/>) is a collaborative spam filtering service.
**Rakismet** is easy Akismet integration with your Rails app, including
support for TypePad's AntiSpam service.


Setup
=====

As a plugin
-----------

Install with `script/plugin install git://github.com/jfrench/rakismet`

Rakismet installation should have created a file called rakismet.rb in
config/initializers. If not, you can copy the template from:
vendor/plugins/rakismet/generators/rakismet/templates/config/initializers/rakismet.rb.

As a gem
--------

`gem install rakismet`

In config/environment.rb, require the gem by adding `config.gem 'rakismet'`
within the config block.

From your app root, run `./script/generate rakismet` to create the Rakismet
initializer.

Getting Started
===============

Once you've installed Rakismet via your method of choice, you'll need an API 
key from the folks at WordPress. Head on over to http://wordpress.com/api-keys/ 
and sign up for a new username.

Edit config/initializers/rakismet.rb and fill in `Rakismet::URL` and
`Rakismet::KEY` with the URL of your application and the key you received
from WordPress.

If you wish to use another Akismet-compatible API provider such as TypePad's
antispam service, you'll also need to change the `Rakismet::HOST` to your
service provider's endpoint.

Rakismet::Model
---------------

First, introduce Rakismet to your model:

    class Comment
	  include Rakismet::Model
	end

Rakismet sends the following information to the spam-hungry robots at Akismet:

    author        : name submitted with the comment
    author_url    : URL submitted with the comment
    author_email  : email submitted with the comment
    comment_type  : 'comment', 'trackback', 'pingback', or whatever you fancy
    content       : the content submitted
    permalink     : the permanent URL for the entry the comment belongs to
    user_ip       : IP address used to submit this comment
    user_agent    : user agent string
    referrer      : http referer

By default, Rakismet just looks for attributes or methods on your class that
match these names. You don't have to have accessors that match these exactly,
however. If yours differ, just tell Rakismet what to call them:

    class Comment
      include Rakismet::Model
      attr_accessor :commenter_name, :commenter_email
      rakismet_attrs :author => :commenter_name,
                     :author_email => :commenter_email
    end

Or you can pass in a proc, to access associations:

    class Comment < ActiveRecord::Base
      include Rakismet::Model
      belongs_to :author
      rakismet_attrs :author => proc { author.name },
                     :author_email => proc { author.email }
    end

Rakismet::Controller
--------------------
Perhaps you want to check a comment's spam status at creation time, and you
have no need to keep track of request-specific information such as the user's
IP, user agent, or referrer.

You can add Rakismet to a controller and the IP, user agent, and referrer will
be taken from the current request instead of your model instance.

    class MyController < ActionController::Base
      include Rakismet::Controller
	end

Since you probably won't be checking for spam in every action, Rakismet takes
`:only` and `:except` options just like other filters. You can reduce overhead
by specifying just the appropriate actions:

    class MyController < ActionController::Base
      include Rakismet::Controller
      rakismet_filter :only => :create
    end

Checking For Spam
=================

Rakismet provides three methods for interacting with Akismet:

 * `spam?`

Simply call `@comment.spam?` to get a true/false response. True means it's spam, false means it's not. Well, usually; it's possible something went wrong
and Akismet returned an error message. `@comment.spam?` will return false if
this happens. You can check `@comment.akismet_response` to be certain;
anything other than 'true' or 'false' means you got an error. That said, as
long as you're collecting the data listed above it's probably sufficient to
check `spam?` alone.

Keep in mind that if you call `spam?` from within a controller action that
uses the Rakismet filter, the user IP, user agent, and referrer will be taken
from the current request regardless of what your model attributes are. In
other words: if you're not verifying comments at the moment they're submitted,
you probably want to store those attributes rather than rely on the controller
methods.

 * `ham!` and 
 * `spam!`

Akismet works best with your feedback. If you spot a comment that was
erroneously marked as spam, `@comment.ham!` will resubmit to Akismet, marked
as a false positive. Likewise if they missed a spammy comment,
`@comment.spam!` will resubmit marked as spam.

Updating from Rakismet < 0.4
----------------------------
There were some significant changes to the API in version 0.4. This was done
to make Rakismet easier to use with persistence layers other than
ActiveRecord.

If you're updating from an older version, please note:

 * Rakismet is no longer automatically injected into ActiveRecord and
   ActionController. You'll need to manually include Rakismet with
   `include Rakismet::Model` and `include Rakismet::Controller`.
 * `ActiveRecord::Base#has_rakismet` now becomes
   `Rakismet::Model#rakismet_attrs`.
 * `ActionController::Base#has_rakismet` now becomes
   `Rakismet::Controller#rakismet_filter`.

--------------------------------------------------------------
Copyright (c) 2008 Josh French, released under the MIT license
