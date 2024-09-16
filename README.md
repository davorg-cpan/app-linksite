# linksite

Self-hosted Linktree clone

A very simple thing that I originally threw together in an hour or so. I
have since spent many hours turning it into something that other people
can also use.

## The important files

* [links.json](https://github.com/davorg-cpan/app-linksite/blob/main/example/links.json) defines the links. 
  Note that this is just an example. You should create your own version of this and store it in a separate repo - see [github.com/davorg/links](https://github.com/davorg/links) for the input that builds my [link site](https://links.davecross.co.uk/).
* [index.html.tt](https://github.com/davorg-cpan/app-linksite/blob/main/src/index.html.tt) defines how the web page looks
* [linksite](https://github.com/davorg-cpan/app-linksite/blob/main/bin/linksite) is the command-line program that actually turns the JSON into a web page
* [build.yml](https://github.com/davorg-cpan/app-linksite/blob/main/examples/build.yml) is a sample GitHub Actions workflow file that you can use as a basis to build your own site automatically

## Demo

My links - https://links.davecross.co.uk/
