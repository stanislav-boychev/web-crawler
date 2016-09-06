## README

## Prerequisites

ruby version
```
➜  gc-web-crawler git:(master) ruby -v
ruby 2.1.5p273 (2014-11-13 revision 48405) [x86_64-linux]
```

bundle `gem bundle install`


## How to run

run `bundle install`

run the web app `rails server`

## How to request site map

go to web browser and request `http://localhost:3000/domains/:domain/assets`

_Example for gocardless.com domain:_ `http://localhost:3000/domains/gocardless.com/assets`

## What can be improved

## Architecture

* The WebCrawlerService uses combination recursion and iteration to collect all the
links on page and the visit them. This is the most intuitive approach. A better aproach can be trying replace recursion altogether with iteration. Although this will decrease the readability of the code it might increase performance

* Implementing PagesMap object that can be used efficiently without creating a new instance on every call can lead to better architectural design and increase maintability and readability. PagesMap will behave like a hash but will have additional behaviour like checking if a page has been visited. In that way reponsibilities can be offloaded from WebCrawlerService

## Performance

* Caching - We can add caching of page map assets. For every url + page we can store
the assets. We can use in-memory store like Redis, schemaless database like NoSQl or
more traditional relational database like Postgres
