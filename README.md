# usmu

**Source:** https://github.com/usmu/usmu  
**Author:** Matthew Scharley  
**Contributors:** [See contributors on GitHub][gh-contrib]  
**Bugs/Support:** [Github Issues][gh-issues]  
**Copyright:** 2014  
**License:** [MIT license][license]  
**Status:** Active

## Synopsis

`usmu` is a static site generator intended to be used with the future Rails-based editing platform. It can also be used
to generate locally if you don't wish to use the web-based editor.

## Installation

    $ gem install usmu

## Usage

TODO: Write usage instructions here

## Compatibility

As a baseline `usmu` will pull in Slim for layouts and Redcarpet for content written in Markdown. However, we use the
Tilt API to render all layouts and content, therefore you should be able to use anything supported by Tilt including
Sass, Less, Textile and [many others][tilt-support] you just need to ensure you have the correct gems installed.

If you want to further [configure the way your template's are processed][template-options] then you can specify 
configurations for each file extension. Just add it to your `usmu.yml`:

```yaml
slim:
  :pretty: true
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

  [gh-contrib]: https://github.com/usmu/usmu/graphs/contributors
  [gh-issues]: https://github.com/usmu/usmu/issues
  [tilt-support]: https://github.com/rtomayko/tilt/blob/master/README.md
  [template-options]: https://github.com/rtomayko/tilt/blob/master/docs/TEMPLATES.md
