Rakismet
========

**Akismet** (<http://akismet.com/>) is a collaborative spam filtering service.
**Rakismet** is easy Akismet integration with Rails and rack apps. TypePad's
AntiSpam service and generic Akismet endpoints are supported.

Compatibility
=============

**Rakismet >= 1.0.0** work with Rails 3 and other Rack-based frameworks.

**Rakismet <= 0.4.2** is compatible with Rails 2.

Getting Started
===============

Once you've installed the Rakismet gem and added it to your application's Gemfile,
you'll need an API key. Head on over to http://akismet.com/signup/ and sign up
for a new username.

Configure the Rakismet key and the URL of your application by setting the following
in application.rb:

```ruby
config.rakismet.key = 'your wordpress key'
config.rakismet.url = 'http://yourdomain.com/'
```

or an initializer, for example `config/initializers/rakismet.rb`:

```ruby
YourApp::Application.config.rakismet.key = 'your wordpress key'
YourApp::Application.config.rakismet.url = 'http://yourdomain.com/'
```

If you wish to use another Akismet-compatible API provider such as TypePad's
antispam service, you'll also need to set `config.rakismet.host` to your service
provider's endpoint.

If you want to use a proxy to access akismet (i.e. your application is behind a
firewall), set the proxy_host and proxy_port option.

```ruby
config.rakismet.proxy_host = 'http://yourdomain.com/'
config.rakismet.proxy_port = '8080'
```

Checking For Spam
-----------------

First, introduce Rakismet to your model:

```ruby
class Comment
  include Rakismet::Model
end
```

With Rakismet mixed in to your model, you'll get three instance methods for interacting with
Akismet:

 * `spam?` submits the comment to Akismet and returns true if Akismet thinks the comment is spam, false if not.
 * `ham!` resubmits a valid comment that Akismet erroneously marked as spam (marks it as a false positive.)
 * `spam!` resubmits a spammy comment that Akismet missed (marks it as a false negative.)

The `ham!` and `spam!` methods will change the value of `spam?` but their
primary purpose is to send feedback to Akismet. The service works best when you
help correct the rare mistake; please consider using these methods if you're
moderating comments or otherwise reviewing the Akismet responses.

Configuring Your Model
----------------------

Rakismet sends the following information to the spam-hungry robots at Akismet:

    author        : name submitted with the comment
    author_url    : URL submitted with the comment
    author_email  : email submitted with the comment
    comment_type  : Defaults to comment but you can set it to trackback, pingback, or something more appropriate
    content       : the content submitted
    permalink     : the permanent URL for the entry the comment belongs to
    user_ip       : IP address used to submit this comment
    user_agent    : user agent string
    referrer      : referring URL (note the spelling)

By default, Rakismet just looks for attributes or methods on your class that
match these names. You don't have to have accessors that match these exactly,
however. If yours differ, just tell Rakismet what to call them:

```ruby
class Comment
  include Rakismet::Model
  attr_accessor :commenter_name, :commenter_email
  rakismet_attrs :author => :commenter_name, :author_email => :commenter_email
end
```

Or you can pass in a proc, to access associations:

```ruby
class Comment < ActiveRecord::Base
  include Rakismet::Model
  belongs_to :author
  rakismet_attrs  :author => proc { author.name },
                  :author_email => proc { author.email }
end
```

You can even hard-code specific fields:

```ruby
class Trackback
  include Rakismet::Model
  rakismet_attrs :comment_type => "trackback"
end
```

Optional Request Variables
--------------------------

Akismet wants certain information about the request environment: remote IP, the
user agent string, and the HTTP referer when available. Normally, Rakismet
asks your model for these. Storing this information on your model allows you to
call the `spam?` method at a later time. For instance, maybe you're storing your
comments in an administrative queue or processing them with a background job.

You don't need to have these three attributes on your model, however. If you
choose to omit them, Rakismet will instead look at the current request (if one
exists) and take the values from the request object instead.

This means that if you are **not storing the request variables**, you must call
`spam?` from within the controller action that handles comment submissions. That
way the IP, user agent, and referer will belong to the person submitting the
comment. If you're not storing the request variables and you call `spam?` at a
later time, the request information will be missing or invalid and Akismet won't
be able to do its job properly.

If you've decided to handle the request variables yourself, you can disable the
middleware responsible for tracking the request information by adding this to
your app initialization:

```ruby
config.rakismet.use_middleware = false
```

Testing
-------

Rakismet can be configued to tell Akismet that it should operate in test mode -
so Akismet will not change its behavior based on any test API calls, meaning
they will have no training effect. That means your tests can be somewhat
repeatable in the sense that one test won't influence subsequent calls.

You can configure Rakismet for test mode via application.rb:

```ruby
config.rakismet.test = false # <- default
config.rakismet.test = true
```

Or via an initializer:

```ruby
YourApp::Application.config.rakismet.test = false # <- default
YourApp::Application.config.rakismet.test = true
```

**NOTE**: When running in Rails, Rakismet will run in test mode when your Rails
environment is `test` or `development`, unless explictly configured otherwise.
Outside of Rails Rakismet defaults to test mode turned **off**.


Verifying Responses
-------------------

If you want to see what's happening behind the scenes, after you call one of
`@comment.spam?`, `@comment.spam!` or `@comment.ham!` you can check
`@comment.akismet_response`.

This will contain the last response from the Akismet server. In the case of
`spam?` it should be `true` or `false.` For `spam!` and `ham!` it should be
`Feedback received.` If Akismet returned an error instead (e.g. if you left out
some required information) this will contain the error message.

FAQ
===

Why does Akismet think all of my test data is spam?
---------------------------------------------------

Akismet needs enough information to decide if your test data is spam or not.
Try to supply as much as possible, especially the author name and request
variables.

How can I simulate a spam submission?
-------------------------------------

Most people have the opposite problem, where Akismet doesn't think anything is
spam. The only guaranteed way to trigger a positive spam response is to set the
comment author to "viagra-test-123".

If you've done this and `spam?` is still returning false, you're probably
missing the user IP or one of the key/url config variables. One way to check is
to call `@comment.akismet_response`. If you are missing a required field or
there was another error, this will hold the Akismet error message. If your comment
was processed normally, this value will simply be `true` or `false`.

Can I use Rakismet with a different ORM or framework?
-----------------------------------------------------

Sure. Rakismet doesn't care what your persistence layer is. It will work with
Datamapper, a NoSQL store, or whatever next month's DB flavor is.

Rakismet also has no dependencies on Rails or any of its components, and only
uses a small Rack middleware object to do some of its magic. Depending on your
framework, you may have to modify this slightly and/or manually place it in your
stack.

You'll also need to set a few config variables by hand. Instead of
`config.rakismet.key`, `config.rakismet.url`, and `config.rakismet.host`, set
these values directly with `Rakismet.key`, `Rakismet.url`, and `Rakismet.host`.

---------------------------------------------------------------------------

If you have any implementation or usage questions, don't hesitate to get in
touch: josh@vitamin-j.com.

Copyright (c) 2008 Josh French, released under the MIT license
