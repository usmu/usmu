# usmu

[![Circle CI](https://circleci.com/gh/usmu/usmu/tree/master.svg?style=svg)](https://circleci.com/gh/usmu/usmu/tree/master)
[![Dependency Status](https://gemnasium.com/usmu/usmu.svg)](https://gemnasium.com/usmu/usmu)
[![Code Climate](https://codeclimate.com/github/usmu/usmu/badges/gpa.svg)](https://codeclimate.com/github/usmu/usmu)

**Source:** [https://github.com/usmu/usmu](https://github.com/usmu/usmu)  
**Author:** Matthew Scharley  
**Contributors:** [See contributors on GitHub][gh-contrib]  
**Bugs/Support:** [Github Issues][gh-issues]  
**Copyright:** 2016  
**License:** [MIT license][license]  
**Status:** Active

## Synopsis

`usmu` is a static site generator intended to be used with the future Rails-based editing platform. It can also be used
to generate locally if you don't wish to use the web-based editor.

## Installation

    $ gem install usmu

## Usage

You can generate a new basic website using `usmu init`.

    $ usmu init site-name

This will create a new site in the `site-name` folder. You can now use `usmu generate` to build the test site.

    $ cd site-name
    $ usmu generate

You can also use `usmu serve` to get a live server that you can use to test changes you make. This will not modify any
files in your output folder but will instead dynamically generate and serve content directly from your files. Note,
this is in no way secure and it is highly recommended to only deploy static versions of your website.

    $ usmu serve

## Compatibility

As a baseline `usmu` will pull in Slim for layouts and Redcarpet for content written in Markdown. However we use the
Tilt API to render all layouts and content, therefore you should be able to use anything supported by Tilt including
Sass, Less, Textile and [many others][tilt-support], you just need to ensure you have the correct gems installed.

If you want to further [configure the way your template's are processed][template-options] then you can specify
configurations for each template engine. Just add it to your `usmu.yml`:

```yaml
slim:
  :pretty: true
```

  [gh-contrib]: https://github.com/usmu/usmu/graphs/contributors
  [gh-issues]: https://github.com/usmu/usmu/issues
  [license]: https://github.com/usmu/usmu/blob/master/LICENSE.md
  [tilt-support]: https://github.com/rtomayko/tilt/blob/master/README.md
  [template-options]: https://github.com/rtomayko/tilt/blob/master/docs/TEMPLATES.md
  [ruby-maint]: https://bugs.ruby-lang.org/projects/ruby/wiki/ReleaseEngineering
