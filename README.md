# Jekyll::Attendease

A Jekyll plugin, brings in data from your Attendease event and allows you to use it in your Jekyll templates for awesome event websites.

![Travis status](https://api.travis-ci.org/attendease/jekyll-attendease.png)

[![Coverage
Status](https://coveralls.io/repos/attendease/jekyll-attendease/badge.svg?branch=master&service=github)](https://coveralls.io/github/attendease/jekyll-attendease?branch=master)

## Changes

### 0.6.37
* Filter root pages so only root page can be listed in the navigation menu

### 0.6.36
* Expose public pages and settings (only `parentPagesAreClickable` for now).

### 0.6.35
* Expose public features for use with event sites and org portals (bypass_pii_consent is the only one for now).

### 0.6.26
* Exclude external pages. Fix the way HTTParty is used so it works in extended classes.
* For event sites, interpolate the `{{ event.foo }}` variables.
* Support for organization sites.
* Skip the generation of old resource pages for organization or new CMS sites.
* Add a means to specify default configuration values by way of lib/jekyll/attendease_plugin/_config.yaml.
* Add portal pages to event_data_generator
* Add generate_sponsor_page option
* Ensure hidden pages don't show up in the nav
* Ensure the attendease_locales_script uses the api_host setting.
* Add site_settings to the data structure.
* Ensure titles are passed to pages properly.
* Generate pre-rendered layouts for all CMS layouts.
* Fix page title.
* Fix the sorting of block instances.
* Page blocks are now stored in a corresponding JSON file
* Test that our data gets generated.
* Add {% attendease_block_renderer %} tag to inject all of the code needed for
  the block renderer.

### 0.6.24

* expose `site.attendease.days` which allows any page to access the days and
  session timeslots on a particular day.
* add an `awesome_inspect` Liquid filter to look at an object
* ensure session filters include the `colour`

### 0.6.23

* minor fix to support alternate sponsor level format

### 0.6.22

* jekyll-attendease now expects Jekyll 3.1.x
* with the `copy_data` option, data files now use a SHA2 digest in the filename.
  The filenames are available as Liquid variables:

```
{{ site.attendease.data_files.event }}
{{ site.attendease.data_files.presenters }}
{{ site.attendease.data_files.venues }}
{{ site.attendease.data_files.sponsors }}
{{ site.attendease.data_files.sessions }}
{{ site.attendease.data_files.filters }}
```

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
  # Required
  api_host: https://your-event-subdomain.attendease.com/
```

### Optional parameters in the `attendease` section:

Key                         | Default            | Description
--------------------------- | ------------------ | -----------
base_layout                 | layout             | When generating pages this will be the base layout for your html
base_email_layout           | email              | When generating an email template this will be the base layout for your html
access_token                | none               | Your top-secret API access token
cache_expiry                | 3600               | The number of seconds until we regerenate the data from the api. Otherwise data will be cached for speed.
generate_schedule_pages     | false              | Set to true if you want to generate static schedule pages.
generate_sponsor_pages      | false              | Set to true if you want to generate static sponsor pages.
show_schedule_index         | false              | Set to true if you want a schedule index page. Otherwise it will just show the first day at /schedule.
schedule_path_name          | schedule           | Folder off of the root to put the schedule pages. Setting to blank will disable schedule page generation.
presenters_path_name        | presenters         | Folder off of the root to put the presenters page. Setting to blank will disable presenter page generation.
venue_path_name             | venue              | Folder off of the root to put the venue venues_path_name            | venues             | Folder off of the root to put the venues page. Setting to blank will disable venue page generation.
sponsors_path_name          | sponsors           | Folder off of the root to put the sponsors page. Setting to blank will disable sponsor page generation.
schedule_sessions_title     | Schedule: Sessions | Override to set the page.title of the sessions listing page
schedule_session_page_title | Schedule: %s       | %s will be substituted with the session's name
presenters_index_title      | Presenters         | Override to set the page.title of the presenters listing page
presenter_page_title        | Presenter: %s      | %s will be substituted with the session's name
venues_index_title          | Venues             | Override to set the page.title property of the Venues index page
venue_page_title            | Venue: %s          | %s will be substituted with venue's name. Override to set the page.title property of the individual Venue page
session_slug_uses_code      | false              | If true, the slugs used for session pages.
copy_data                   | false              | If true, the API-provided data gets copied to an 'attendease_data' folder which will be available for consumption by your Javascript

Remember to replace `https://your-event-subdomain.attendease.com/` with your actual event url, or crazy things will happen!

## Usage

Now the event name can easily be used in your site like so:

`{{ site.attendease.data.event_name }}`

We can also use logical expressions like so:

```
{% if site.attendease.data.has_registration %}
  We have registration!
{% endif %}
```

## Magic Attendease Tags

Simply add the auth script tag and the auth action and account tags and our system will know if you logged in or out and will be able to link to your account!

The script tag sets up an AJAX callback to the server to determine if we are online or offline.

`{% attendease_auth_script %}`

This is simple a div with the id `attendease-auth-account`, maybe more in the future. When used with the `attendease_auth_script` tag it will populate with the link to the account of the attendee.

`{% attendease_auth_account %}`

This is simple a div with the id `attendease-auth-action`, maybe more in the future. When used with the `attendease_auth_script` tag it will populate with a `login` or `logout` action.

`{% attendease_auth_action %}`

This script tag sets up AJAX actions for scheduling sessions.

`{% attendease_scheduler_script %}`

This script tag sets up lingo so your event can sound like you want it to sound like.

`{% attendease_locales_script %}`

A quick way to use our lingo stuff in our jekyll templates.

`{% attendease_t %}`

Output the supporting code to load in the Attendease CMS block renderer.

`{% attendease_block_renderer %}`

You can pass in an optional URL to override where the bundle is found:

`{% attendease_block_renderer https://foobar.cdn/blockrenderer-latest.js %}`

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

## Static Schedule Pages

In your `_config.yml` if you add the `generate_schedule_pages` set to `true` under `attendease` it will generate static schedule pages from the Attendease public API.

You can customize the look/structure of each page as well as widgets within the pages. These pages will be automatically generated for you when you build your site.

For Session Day pages:

- `_layouts/attendease_schedule_day_sessions.html` - The layout for the generate session day page. It will list all instances on that day
- `_includes/attendease/session_instance_item.html` - The instance item on the page
- `_includes/attendease/filter.html` - A filter and its items in the instance
- `_includes/attendease/presenter_item.html` - A presenter item in the instance

## Available Data

Using the `site.attendease` structure, you can access the following datasets:
datasets:

Key         | Description                                                        | Type
----------- | ------------------------------------------------------------------ | ----
site        | Includes various information about the event/site (/api/site.json) | Hash
event       | Event data such as dates (/api/event.json)                         | Hash
sessions    | All of the sessions for the event (/api/sessions.json)             | Array
presenters  | All of the presenters for the event (/api/presenters.json)         | Array
rooms       | All of the room data for the event (/api/rooms.json)               | Array
filters     | All of the event's filters (/api/filters.json)                     | Array
venues      | All of the venue data for the event (/api/venues.json)             | Array
sponsors    | All of the sponsor data for the event (/api/sponsors.json)         | Array
lingo       | All of the locale-related data for the event                       | Hash
days        | All of the event days and session timeslots contained therein      | Array

Liquid Example:

```
{% for session in site.attendease.sessions %}
  {{ session.name }}
{% endfor %}
```

```
{% for day in site.attendease.days %}
  {{ day.date_formatted }}
  {% for instance in day.instances %}
    {{ instance.time }} - {{ instance.end_time }}

    {{ instance.session.name }}
    {{ instance.session.description }}
  {% endfor %}
{% endfor %}
```

## Filters

The following Liquid filters are available as part of this gem:

Filter            | Description
----------------- | ----------------------------------------------------------
`json`            | Convert an object to a JSON string
`awesome_inspect` | Pretty print an object in HTML (for debugging/inspecting)


## Testing

1. Make sure the specs pass! `bundle exec rake spec`
2. Add new specs if you've added new functionality.


## Preparing for a release

1. Start with a pre-release version. Adding non-numeric characters achieves
   this. (e.g. 0.6.13.pre in `lib/jekyll/attendease_plugin/version.rb`)
2. Update the gem's release date in `jekyll-attendease.gemspec`
3. `gem build jekyll-attendease.gemspec`
4. `gem push jekyll-attendease-0.6.13.pre.gem`
5. Update Attendease respectively to test.


## Releasing final version

1. Bump the version
2. Tag the release
3. Build and push the gem
4. Push the tags to the upstream


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Updating the gem on beta and production

1. log into the jail via the jail's console.
2. gem install jekyll-attendease -v x.x.x

## Testing

During development, you can create and install local builds:

`gem build jekyll-attendease.gemspec`

And then install it:

    gem install jekyll-attendease-`cat lib/jekyll/attendease_plugin/version.rb|grep VERSION|awk '{print $3}'|sed s/\'//g`.gem

## License

Copyright (C) 2013 Attendease (https://attendease.com/)

The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
