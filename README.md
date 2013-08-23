# Jekyll::Attendease

A Jekyll plugin, brings in data from your Attendease event and allows you to use it in your Jekyll templates for awesome event websites.

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-attendease'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-attendease


Next, make sure to require it. Add the following file `_plugins/attendease.rb` and content:

``` ruby
require "jekyll-attendease"
```

## Configuration

You will need to configure by editing your `_config.yml`:

``` yaml
#
# Plugin: jekyll-attendease
#
attendease:
  api_host: https://your-event-subdomain.attendease.com/
  test_mode: true # this generates pages for /regsister, /schedule, and /presenters for local development and styling.
```

Remember to replace `https://your-event-subdomain.attendease.com/` with your actual event url, or crazy things will happen!

Setting `test_mode` will create pages for /register, /schedule and
/presenters. You may style these pages, but they are non-functional.
When the site is deployed to Attendease these will function.

## Usage

Now the event name can easily be used in your site like so:

`{{ site.attendease.data.attendease_event_name }}`

We can also use logical expressions like so:

```
{% if site.attendease.data.attendease_has_registration %}
  We have registration!
{% endif %}
```

## Magic Auth Tag

Simply add the auth script tag and the auth action and account tags and our system will know if you logged in or out and will be able to link to your account!

The script tag sets up an ajax callback to the server to determine if we are online or offline.
`{% attendease_auth_script %}`

This is simple a div with the id `attendease-auth-account`, maybe more in the future. When used with the `attendease_auth_script` tag it will populate with the link to the account of the attendee.

`{% attendease_auth_account %}`

This is simple a div with the id `attendease-auth-action`, maybe more in the future. When used with the `attendease_auth_script` tag it will populate with a `login` or `logout` action.

`{% attendease_auth_action %}`

## Listening for the auth callback

In your site's Javascript, do something like this:

``` javascript
JekyllAttendease.onLoginCheck(function(e)
{
  if (e.data.loggedin)
  {
    // do some cool stuff!
    var account = e.data.account;
    // console.log(account);
  }

  // And we have some URLs for you!
  // e.data.loginURL
  // e.data.logoutURL
  // e.data.accountURL
});
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

During development, you can create and install local builds:

`gem build jekyll-attendease.gemspec`

And then install it:

`gem install jekyll-attendease-``cat jekyll-attendease.gemspec|grep s.version|awk '{print $3}'|sed s/\'//g```

(where `x.x.x` is the version you've defined in the gemspec)

## License

Copyright (C) 2013 Attendease (https://attendease.com/)

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
