XSD Explorer allows a user to browse through an XML Schema in a web browser. The output is entirely HTML and JavaScript, which creates a simple and clean interface for exploring a potentially complex XML schema. Schema `include` files are loaded and incorporated so that base types and extensions are shown within the schema tree. Attributes, documentation and enumerations are displayed in an information pane on the screen, and the underlying XML structure for a particular element can be inspected easily.

The app runs Ruby on the lightweight [Sinatra](http://www.sinatrarb.com) framework and uses [Nokogiri](http://nokogiri.org) to parse the XSD and [Twitter Bootstrap](http://getbootstrap.com) to create the UI. When a schema is requested, the HTML is generated in the background and persisted to S3, where it is served for future display on screen.

# Get Started
Download and use:

```
git clone https://github.com/mattharris5/xsd-explorer

cd xsd-explorer
bundle install             # To install sinatra and dependencies
bundle exec ruby app.rb    # To run the app
```

Then open http://localhost:4567/

## Configuration variables
The following variables should be available as environment variables:

* REDIS_URL
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* S3_BUCKET_NAME
* AWS_REGION
* RACK_ENV

## What's next?
Try the rerun gem to restart Sinatra automatically when you change source files: https://github.com/alexch/rerun

You might also want to add your own schemas into the `/public/schemas` directory.

# Contributing
Please feel free to suggest improvements by forking this repo and contributing a pull request.

## License
Copyright (c) 2016 [Matt Harris](http://github.com/mattharris5)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
