Rakismet
========

**Akismet** (<http://akismet.com/>) is a collaborative spam filtering service.
**Rakismet** is easy Akismet integration with your Rails app, including support
for TypePad's AntiSpam service.


Setup
=====

Install with `script/plugin install git://github.com/jfrench/rakismet`

To get up and running with Rakismet, you'll need an API key from the folks at
WordPress. Head on over to http://wordpress.com/api-keys/ and sign up for a
new username.

Rakismet installation should have created a file called rakismet.rb in
config/initializers. Add your WordPress key and the front page or home URL of
your app. Rakismet::URL must be a fully qualified URI including the http://.

If that file is missing, create it and add the following:

    Rakismet::KEY  = 'your key from WordPress'
    Rakismet::URL  = 'http://base url for your application/'
    Rakismet::HOST = 'rest.akismet.com'

The Rakismet host can be changed if you wish to use another Akismet-compatible
API provider such as TypePad's antispam service.

Now introduce Rakismet to your application. Let's assume you have a Comment
model and a CommentsController:

    class Comment < ActiveRecord::Base
      has_rakismet
    end

    class CommentsController < ActionController::Base
      has_rakismet
    end


Basic Usage
===========

Rakismet provides three methods for interacting with Akismet:

  `spam?`

From within a CommentsController action, simply call `@comment.spam?` to get a
true/false response. True means it's spam, false means it's not. Well,
usually; it's possible something went wrong and Akismet returned an error
message. `@comment.spam?` will return false if this happens. You can check
`@comment.akismet_response` to be certain; anything other than 'true' or
'false' means you got an error. That said, as long as you're collecting the
data listed above it's probably sufficient to check `spam?` alone.

  `ham!` and `spam!`

Akismet works best with your feedback. If you spot a comment that was
erroneously marked as spam, `@comment.ham!` will resubmit to Akismet, marked
as a false positive. Likewise if they missed a spammy comment,
`@comment.spam!` will resubmit marked as spam.


What's Required in the Comment Model?
=====================================

Rakismet sends the following information to the spam-hungry robots at Akismet.
This means these attributes should be stored in your Comment model or
accessible through that class's associations.

    author        : name submitted with the comment
    author_url    : URL submitted with the comment
    author_email  : email submitted with the comment
    comment_type  : 'comment', 'trackback', 'pingback', or whatever you fancy
    content       : the content submitted
    permalink     : the permanent URL for the entry the comment belongs to
    user_ip       : IP address used to submit this comment
    user_agent    : user agent string
    referrer      : http referer

`user_ip`, `user_agent`, and `referrer` are optional; you don't have to store
them, but it's a good idea. If you omit them from your model (see "Customizing
Attributes"), the `spam?` method will attempt to extract these values from the
current request object, if there is one. This means Rakismet can operate
asynchronously by storing the request attributes and validating the comment at
a later time. Or it can operate synchronously by plucking the request
attributes from the environment at the time the comment is initially submitted
and validating on the spot. The latter could work well with a before_create
callback.


Customizing the Comment Model
=============================

If your attribute names don't match those listed above, or if some of them
live on other objects, you can pass `has_rakismet` a hash mapping the default 
attributes to your own. You can change the names, if your comment attributes
don't match the defaults:

    class Comment < ActiveRecord::Base
      has_rakismet :author => :commenter_name,
                   :author_email => :commenter_email
    end

Or you can pass in a proc, to access associations:

    class Comment < ActiveRecord::Base
      belongs_to :author
      has_rakismet :author => proc { author.name },
                   :author_email => proc { author.email }
    end

For any attribute you don't specify, Rakismet will try to find an attribute or 
method matching the default name. As mentioned above, if `user_ip`,
`user_agent`, and `referrer` are not present on your model, Rakismet will
attempt to find them in the request environment when `spam?` is called from
within a Rakismet-aware controller action.

Customizing the Comments Controller
===================================

Most of the time you won't be checking for spam on every action defined in
your controller. If you only call `spam?` within `CommentsController#create` 
and you'd like to reduce filter overhead, `has_rakismet` takes `:only` and
`:except` parameters that work like the standard before/around/after filter
options.

    class CommentsController < ActionController::Base
      has_rakismet :only => :create
    end


--------------------------------------------------------------
Copyright (c) 2008 Josh French, released under the MIT license
