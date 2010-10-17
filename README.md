Rakismet
========

**Akismet** (<http://akismet.com/>) is a collaborative spam filtering service.
**Rakismet** is easy Akismet integration with Rails and rack apps. TypePad's
AntiSpam service and generic Akismet endpoints are supported.

Getting Started
===============

Once you've installed the Rakismet gem and added it to your application's Gemfile,
you'll need an API key from the folks at WordPress. Head on over to
http://wordpress.com/api-keys/ and sign up for a new username.

Configure the Rakismet key and the URL of your application by setting the following
in an initializer or application.rb:

    config.rakismet.key = 'your wordpress key'
    config.rakismet.url = 'http://yourdomain.com/'

If you wish to use another Akismet-compatible API provider such as TypePad's
antispam service, you'll also need to set `config.rakismet.host` to your service
provider's endpoint.

Adding Rakismet to Your Application
-----------------------------------

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
    remote_ip     : IP address used to submit this comment
    user_agent    : user agent string
    referer       : http referer (note the HTTP-style spelling.)

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


Checking For Spam
-----------------

Rakismet provides three methods for interacting with Akismet:

 * `spam?`

Simply call `@comment.spam?` to get a true/false response. True means it's spam,
false means it's not. (In case of an error, `@comment.spam?` will also return
false. If you want to make sure your Akismet requests are behaving properly,
you can check `@comment.akismet_response`. Anything other than "true" or
"false" means you got an error. But as long as you're collecting the data
above, it's probably safe to rely on `@comment.spam?` alone.)

 * `ham!` and 
 * `spam!`

Akismet works best with your feedback. If you spot a comment that was
erroneously marked as spam, `@comment.ham!` will resubmit to Akismet, marked
as a false positive. Likewise if they missed a spammy comment,
`@comment.spam!` will resubmit marked as spam.

Optional Request Variables
--------------------------

Akismet wants certain information about the request environment: remote IP, the
user agent string, and the HTTP referer when available. Normally, Rakismet
asks your model for these. Storing this information on your model allows you to
call the `spam?` method at a later time, e.g. you're putting your comments into
an administrative queue or using a background job to process them.

You don't need to have these three attributes on your model, however. If you
choose to omit them, Rakismet will instead look for a current request object
and ask it for the values instead.

This means that if you are **not storing request variables**, you must call
`spam?` from within the controller action that handles comment submissions. That
way the IP, user agent, and referer will belong to the person submitting the
comment. If you were to call `spam?` at a later time, the request information would
be invalid. 

If you've decided to handle the request variables yourself and would like to
disable the middleware responsible for inspecting each request, add this to your
app initialization:

    config.rakismet.use_middleware = false


--------------------------------------------------------------
Copyright (c) 2008 Josh French, released under the MIT license
