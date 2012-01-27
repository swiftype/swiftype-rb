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

#### DocumentType

`DocumentTypes` specify the structure of a set of documents in the `Engine` and are the entry point for searches.  There are three types of fields on a `DocumentType`: `text_fields`, `body_fields`, and `feature_fields`.

`text_fields` are short strings that can be matched in both prefix and full-text searches.  _Example: Chapter titles in a book._

`body_fields` can be long strings.  The are meant for full-text searches only and will not be used for prefix queries.  _Example: Entire text of an essay._

`feature_fields` are the traits of a document.  They are not analyzed in any way, and thus can be used to filter and sort queries.  _Example: Price of a book._

#### Document

`Documents` represent all of the pieces of content in an `Engine`.  They are children of a `DocumentType` and conform to its field specification (note: you do *not* need to specify the fields ahead of time, they will be inferred by the contents of a document).  When you perform a search on a `DocumentType`, you will receive `Document` results.  `external_id` is the only required field for a `Document`. It can be any value, such as a numeric ID.


Basic Usage
-------------

#### Creating an engine

    engine = Engine.new(:name => "Bookstore")
    engine.create!

#### Finding an engine

    engine = Engine.find("bookstore")

#### Creating a document type

    engine = Engine.find("bookstore")
    type = engine.create_document_type(:name => "Book")

#### Inspecting document types

    engine = Engine.find("bookstore")
    types = engine.document_types

#### Adding a document

    engine = Engine.find("bookstore")
    type = engine.document_types.last
    type.create_document(
      :external_id => '1234',
      :text_fields => {
        :title => 'Introduction to Information Retrieval',
        :author => 'Christopher Manning'
      },
      :body_fields => {
        :text => "Lorem ipsum dolor sit amet..."
      },
      :feature_fields => {
        :price => '29.99'
      }
    )

#### Full-text search

    engine = Engine.find("bookstore")
    type = engine.document_types.last
    type.search("inverted index")

#### Search suggestions (prefix query)

    engine = Engine.find("bookstore")
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