# Swiftype::Easy - Simple Swiftype API Client with no dependencies

This is a simple client for the Swiftype API with no dependencies outside core Ruby (for 1.9; Ruby 1.8 require the JSON gem).

This library is a direct pass-through to the Swiftype API. It does not use intermediate objects or return them. All parameters and return values are simple Ruby objects.

We are providing this library for users who may not be able to install our other gem due to dependency conflicts, 
but would like an easier way to access the API than constructing requests by hand.

For a more full-featured API library, see [swiftype-rb](https://github.com/swiftype/swiftype-rb).

## Note: Work In Progress

This is a work in progress. Of particular note, it is not currently possible to have the `swiftype` and `swiftype_easy` gems installed at the same time.

## Usage

### Configuration:

Before issuing commands to the API, configure the client with your API key:

	Swiftype::Easy.configure do |config|
          config.api_key = 'YOUR_API_KEY'
	end

### Create a Simple Client

	client = Swiftype::Easy.new

### Search

	results = client.search('bookstore',{SEARCH QUERY} [, OPTIONAL SEARCH OPTIONS])

### Autocomplete

	results = client.suggest('bookstore',{AUTOCOMPLETE PREFIX QUERY} [, OPTIONAL SEARCH OPTIONS])

### Engines

	client.engines # retrieves every engine
	client.create_engine(:name => 'bookstore')
	client.destroy_engine('bookstore')

### Document Types

	client.document_types('bookstore')
	client.create_document_type('bookstore', :name => 'books')
	client.destroy_document_type('bookstore', 'books')

### Documents

	# retrieve all documents
	client.documents('bookstore', 'books')

	# create a document
	client.create_document('bookstore', 'books', {
		:external_id => '1',
		:fields => [
			{:name => 'title', :value => 'Information Retrieval', :type => 'string'},
			{:name => 'genre', :value => 'non-fiction', :type => 'enum'},
			{:name => 'author', :value => 'Stefan Buttcher', :type => 'string'},
			{:name => 'in_stock', :value => true, :type => 'enum'},
			{:name => 'on_sale', :value => false, :type => 'enum'}
		]})

	# create documents in bulk
	client.create_documents('bookstore', 'books', [{
		:external_id => '2',
		:fields => [
			{:name => 'title', :value => 'Lucene in Action', :type => 'string'},
			{:name => 'genre', :value => 'non-fiction', :type => 'enum'},
			{:name => 'author', :value => 'Michael McCandless', :type => 'string'},
			{:name => 'in_stock', :value => true, :type => 'enum'},
			{:name => 'on_sale', :value => false, :type => 'enum'}
		]},{
		:external_id => '3',
		:fields => [
			{:name => 'title', :value => 'MongoDB in Action', :type => 'string'},
			{:name => 'genre', :value => 'non-fiction', :type => 'enum'},
			{:name => 'author', :value => 'Kyle Banker', :type => 'string'},
			{:name => 'in_stock', :value => true, :type => 'enum'},
			{:name => 'on_sale', :value => false, :type => 'enum'}
		]}])

	# update a document
	client.update_document('bookstore','books','1', { :in_stock => false })

	# update documents in bulk
	client.update_documents('bookstore','books', [
		{:external_id => '2', :fields => {:in_stock => false}},
		{:external_id => '3', :fields => {:in_stock => true}}
	])

	# create or update a document
	client.create_or_update_document('bookstore', 'books', {
		:external_id => '1',
		:fields => [
			{:name => 'title', :value => 'Information Retrieval', :type => 'string'},
			{:name => 'genre', :value => 'non-fiction', :type => 'enum'},
			{:name => 'author', :value => 'Stefan Buttcher', :type => 'string'},
			{:name => 'in_stock', :value => false, :type => 'enum'},
			{:name => 'on_sale', :value => true, :type => 'enum'}
		]})

	# destroy a document
	client.destroy_document('bookstore','books','1')

	# destroy documents in bulk
	client.destroy_documents('bookstore','books',['1','2','3'])


## Todo

* Add specs with webmock 
* Pull `Swiftype::Easy` from the swiftype gem so they are compatable
