Swiftype Ruby Client (beta)
=========

The official [Swiftype](http://swiftype.com) Ruby client for communicating with the Swiftype API. Learn more about Swiftype by visiting [swiftype.com](http://swiftype.com) and creating an account.

Prerequisites
------------
1. A Swiftype account. Sign up at [swiftype.com](http://swiftype.com).
2. A compatible Ruby environment.


Installation
------------

For now, just clone this repository and then pull in the library:

`rake build && rake install`

`require 'swiftype'`

Overview
-----

The client has a few basic methods on `Swiftype` for dealing with `Engines`.  Beyond that, you can perform standard (CRUD) operations on any of the resources.

### Resources

#### Engine

`Engines` are the top-level objects in Swiftype.  They have a free-form `name` field that is translated into a `slug` identifier.

#### Document Type

`DocumentTypes` specify the structure of a set of documents in the `Engine` and are the entry point for searches.  There are three types of fields on a `DocumentType`: `:string`, `:text`, `:enum`, `:integer`, `:float`, and `:date`.

`:string` is for short strings that can be matched in both prefix and full-text searches.  _Example: Chapter titles in a book._

`:text` can be long strings.  They are meant for full-text searches only and will not be used for prefix queries.  _Example: Entire text of an essay._

`:enum` are string traits of a document.  They are not analyzed in any way, and thus can be used to filter and sort queries.  _Example: Hardcover or paperback._

`:date` are ISO 8601 compatible time strings.  They can also be used to filter and sort queries.



#### Document

`Documents` represent all of the pieces of content in an `Engine`.  They are children of a `DocumentType` and conform to its field specification (note: you do *not* need to specify the fields ahead of time, they will be inferred by the contents of a document).  When you perform a search on a `DocumentType`, you will receive `Document` results.  `external_id` is the only required field for a `Document`. It can be any value, such as a numeric ID.


Basic Usage
-------------

#### Configuration

    Swiftype.configure do |config|
      config.username = "you@company.com"
      config.password = "secret"
    end

#### Creating an engine

    engine = Swiftype::Engine.new(:name => "Bookstore")
    engine.create!

#### Finding an engine

    engine = Swiftype::Engine.find("bookstore")

#### Creating a document type

    engine = Swiftype::Engine.find("bookstore")
    type = engine.create_document_type(:name => "Book")

#### Inspecting document types

    engine = Swiftype::Engine.find("bookstore")
    types = engine.document_types

#### Adding a document

    engine = Swiftype::Engine.find("bookstore")
    type = engine.document_types.last
    type.create_document(
      :external_id => '1234',
      :fields => [
        {
          :name => :title,
          :value => "Introduction to Information Retrieval",
          :type => :string
        },
        {
          :name => :body,
          :value => "Lorem ipsum dolor sit amet...",
          :type => :text
        },
        {
          :name => :genre,
          :value => "non-fiction",
          :type => :enum
        },
        {
          :name => :published_on,
          :value => "98/02/17",
          :type => :date
        }
      ]
    )

#### Full-text search

    engine = Swiftype::Engine.find("bookstore")
    type = engine.document_types.last
    type.search("inverted index")

#### Search suggestions (prefix query)

    engine = Swiftype::Engine.find("bookstore")
    type = engine.document_types.last
    type.suggest("Chris")


Todo
----------

+ Proper response code handling for non-successful requests.
+ Publish gem to rubygems.org
+ Tests!


Questions?
----------
Get in touch! We would be happy to help you get up and running.

[Quin](mailto:quin@swiftype.com) and [Matt](mailto:matt@swiftype.com) from [Swiftype](http://swiftype.com)