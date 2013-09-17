require 'spec_helper'

describe Swiftype::Client do
  let(:engine_slug) { 'swiftype-api-example' }
  let(:client) { Swiftype::Client.new }

  before :each do
    Swiftype.api_key = 'hello'
  end

  context 'Search' do
    context '#search' do
      it 'searches all DocumentTypes in the engine' do
        VCR.use_cassette(:engine_search) do
          results = client.search(engine_slug, 'cat')
          results.document_types.size.should == 2
          results['videos'].size.should == 2
          results['channels'].size.should == 1
        end
      end

      it 'searches the engine with options' do
        VCR.use_cassette(:engine_search_pagination) do
          results = client.search(engine_slug, 'cat', {:page => 2})
          results.document_types.size.should == 2
          results['videos'].size.should == 0
          results['channels'].size.should == 0
        end
      end

      it 'includes facets when requested' do
        VCR.use_cassette(:engine_search_facets) do
          results = client.search(engine_slug, nil, {:facets => {:videos => ['category_id']}})
          results.document_types.size.should == 2
          results.facets('channels').should be_empty
          results.facets('videos')['category_id'].should == {
            "23" => 4,
            "28" => 2,
            "15" => 2,
            "25" => 1,
            "22" => 1,
            "2" => 1,
            "10" => 1
          }
        end
      end
    end

    context '#search_document_type' do
      let(:document_type_slug) { 'videos' }

      it 'searches only the provided DocumentType' do
        VCR.use_cassette(:document_type_search) do
          results = client.search_document_type(engine_slug, document_type_slug, 'cat')
          results.document_types.should == ['videos']
          results['videos'].size.should == 2
        end
      end

      it 'searches the DocumentType with options' do
        VCR.use_cassette(:document_type_search_pagination) do
          results = client.search_document_type(engine_slug, document_type_slug, 'cat', {:page => 2})
          results.document_types.should == ['videos']
          results[document_type_slug].size.should == 0
        end
      end
    end
  end

  context 'Suggest' do
    context '#suggest' do
      it 'does prefix searches for all DocumentTypes in the engine' do
        VCR.use_cassette(:engine_suggest) do
          results = client.suggest(engine_slug, 'goo')
          results.document_types.size.should == 2
          results['videos'].size.should == 1
          results['channels'].size.should == 1
        end
      end

      it 'suggests for an engine with options' do
        VCR.use_cassette(:engine_suggest_pagination) do
          results = client.suggest(engine_slug, 'goo', {:page => 2})
          results.document_types.size.should == 2
          results['videos'].size.should == 0
          results['channels'].size.should == 0
        end
      end
    end

    context '#suggest_document_type' do
      let(:document_type_slug) { 'videos' }

      it 'does a prefix search on the provided DocumentType' do
        VCR.use_cassette(:document_type_suggest) do
          results = client.suggest_document_type(engine_slug, document_type_slug, 'goo')
          results.document_types.should == ['videos']
          results['videos'].size.should == 1
        end
      end

      it 'suggests for a document types with options' do
        VCR.use_cassette(:document_type_suggest_pagination) do
          results = client.suggest_document_type(engine_slug, document_type_slug, 'goo', {:page => 2})
          results.document_types.should == ['videos']
          results[document_type_slug].size.should == 0
        end
      end
    end
  end


  context 'Engine' do
    it 'gets all engines' do
      VCR.use_cassette(:list_engines) do
        engines = client.engines
        engines.size.should == 6
      end
    end

    it 'gets an engine' do
      VCR.use_cassette(:find_engine) do
        engine = client.engine(engine_slug)
        engine['slug'].should == engine_slug
      end
    end

    it 'creates engines' do
      VCR.use_cassette(:create_engine) do
        engine = client.create_engine('new engine from spec')
        engine['slug'].should == 'new-engine-from-spec'
      end
    end

    it 'destroys engines' do
      VCR.use_cassette(:destroy_engine) do
        response = client.destroy_engine('new-engine-from-spec')
        response.should be_nil
      end
    end
  end

  context 'DocumentType' do
    let(:document_type_slug) { 'videos' }

    it 'gets all document types' do
      VCR.use_cassette(:list_document_type) do
        document_types = client.document_types(engine_slug)
        document_types.size.should == 2
        document_types.map { |dt| dt['name'] }.sort.should == ['channels', 'videos']
      end
    end

    it 'gets a document type' do
      VCR.use_cassette(:find_document_type) do
        document_type = client.document_type(engine_slug, document_type_slug)
        document_type['slug'].should == document_type_slug
      end
    end

    it 'creates a document type' do
      VCR.use_cassette(:create_document_type) do
        name = document_type_slug
        document_type = client.create_document_type(engine_slug, 'new_doc_type')
        document_type['name'].should == 'new_doc_type'
        document_type['slug'].should == 'new-doc-type'
      end
    end

    it 'destroys document types' do
      VCR.use_cassette(:destroy_document_type) do
        response = client.destroy_document_type(engine_slug, 'new-doc-type')
        response.should be_nil
      end
    end

    it 'raises an error if deleting a non-existent DocumentType' do
      VCR.use_cassette(:destroy_non_existent_document_type) do
        expect do
          response = client.destroy_document_type(engine_slug, 'not_there')
        end.to raise_error
      end
    end
  end

  context 'Document' do
    let(:document_type_slug) { 'videos' }
    let(:document_id) { 'FtX8nswnUKU'}
    let(:documents) do
      [{'external_id'=>'INscMGmhmX4',
         'fields' => [{'name'=>'url', 'value'=>'http://www.youtube.com/watch?v=v1uyQZNg2vE', 'type'=>'enum'},
                      {'name'=>'thumbnail_url', 'value'=>'https://i.ytimg.com/vi/INscMGmhmX4/mqdefault.jpg', 'type'=>'enum'},
                      {'name'=>'channel_id', 'value'=>'UCTzVrd9ExsI3Zgnlh3_btLg', 'type'=>'enum'},
                      {'name'=>'title', 'value'=>'The Original Grumpy Cat', 'type'=>'string'},
                      {'name'=>'category_name', 'value'=>'Pets &amp; Animals', 'type'=>'string'}]},
       {'external_id'=>'XfY9Dsg_DZk',
         'fields' => [{'name'=>'url', 'value'=>'http://www.youtube.com/watch?v=XfY9Dsg_DZk', 'type'=>'enum'},
                      {'name'=>'thumbnail_url', 'value'=>'https://i.ytimg.com/vi/XfY9Dsg_DZk/mqdefault.jpg', 'type'=>'enum'},
                      {'name'=>'channel_id', 'value'=>'UC5VA5j05FjETg-iLekcyiBw', 'type'=>'enum'},
                      {'name'=>'title', 'value'=>'Corgi talks to cat', 'type'=>'string'},
                      {'name'=>'category_name', 'value'=>'Pets &amp; Animals', 'type'=>'string'}]}]
    end

    it 'lists documents in a document type' do
      VCR.use_cassette(:list_documents) do
        documents = client.documents(engine_slug, document_type_slug)
        documents.size.should == 2
      end
    end

    it 'lists documents with pagination' do
      VCR.use_cassette(:list_documents_with_pagination) do
        documents = client.documents(engine_slug, document_type_slug, 2, 2)
        documents.size.should == 2
      end
    end

    it 'find a document' do
      VCR.use_cassette(:find_document) do
        document = client.document(engine_slug, document_type_slug, document_id)
        document['external_id'].should == document_id
      end
    end

    it 'creates a document' do
      VCR.use_cassette(:create_document) do
        document = client.create_document(engine_slug, document_type_slug, documents.first)
        document['external_id'].should == 'INscMGmhmX4'
      end
    end

    it 'bulk create multiple documents' do
      VCR.use_cassette(:bulk_create_documents) do
        response = client.create_documents(engine_slug, document_type_slug, documents)
        response.should == [true, true]
      end
    end

    it 'destroys a document' do
      VCR.use_cassette(:destroy_document) do
        response = client.destroy_document(engine_slug, document_type_slug, 'INscMGmhmX4')
        response.should be_nil
      end
    end

    it 'destroys multiple documents' do
      VCR.use_cassette(:bulk_destroy_documents) do
        response = client.destroy_documents(engine_slug, document_type_slug, ['INscMGmhmX4', 'XfY9Dsg_DZk'])
        response.should == [true, true]
      end
    end

    context '#create_or_update_document' do
      it 'creates a document' do
        VCR.use_cassette(:create_or_update_document_create) do
          response = client.create_or_update_document(engine_slug, document_type_slug, {:external_id => 'foobar', :fields => [{:type => :string, :name => 'title', :value => 'new document'}]})
          response['external_id'].should == 'foobar'
          response['title'].should == 'new document'
        end
      end

      it 'updates an existing document' do
        VCR.use_cassette(:create_or_update_document_update) do
          response = client.create_or_update_document(engine_slug, document_type_slug, {:external_id => document_id, :fields => [{:type => :string, :name => 'title', :value => 'new title'}]})
          response['external_id'].should == document_id
          response['title'].should == 'new title'
        end
      end
    end

    context '#bulk_create_or_update_documents' do
      it 'returns true for all documents successfully created or updated' do
        VCR.use_cassette(:bulk_create_or_update_documents_success) do
          response = client.create_or_update_documents(engine_slug, document_type_slug, documents)
          response.should == [true, true]
        end
      end

      it 'returns false if a document cannot be created or updated due to an error' do
        documents = [{:external_id => 'failed_doc', :fields => [{:type => :string, :name => :title}]}] # missing value

        VCR.use_cassette(:bulk_create_or_update_documents_failure) do
          response = client.create_or_update_documents(engine_slug, document_type_slug, documents)
          response.should == [false]
        end
      end
    end

    context '#update_document' do
      it 'updates a document given its id and fields to update' do
        fields = {:title => 'awesome new title', :channel_id => 'UC5VA5j05FjETg-iLekcyiBw'}
        VCR.use_cassette(:update_document) do
          response = client.update_document(engine_slug, document_type_slug, document_id, fields)
          response['external_id'].should == document_id
          response['title'].should == 'awesome new title'
          response['channel_id'].should == 'UC5VA5j05FjETg-iLekcyiBw'
        end
      end

      it 'raises an error if a unknown field is included' do
        fields = {:not_a_field => 'not a field'}

        VCR.use_cassette(:update_document_unknown_field_failure) do
          expect do
            response = client.update_document(engine_slug, document_type_slug, document_id, fields)
          end.to raise_error
        end
      end
    end

    context "#update_documents" do
      it 'returns true for each document successfully updated' do
        documents = [{:external_id => 'INscMGmhmX4', :fields => {:title => 'hi'}}, {:external_id => 'XfY9Dsg_DZk', :fields => {:title => 'bye'}}]

        VCR.use_cassette(:update_documents_success) do
          response = client.update_documents(engine_slug, document_type_slug, documents)
          response.should == [true, true]
        end
      end

      it 'returns false if document is not successfully updated' do
        documents = [{:external_id => 'not_there', :fields => [{:name => :title, :value => 'hi', :type => :string}]}]

        VCR.use_cassette(:update_documents_failure_non_existent_document) do
          response = client.update_documents(engine_slug, document_type_slug, documents)
          response.should == [false]
        end
      end
    end
  end

  context 'Analytics' do
    let(:engine_slug) { 'recursion' }

    context '#analytics_searches' do
      it 'returns search counts for the default time frame' do
        VCR.use_cassette(:analytics_searches) do
          searches = client.analytics_searches(engine_slug)
          searches.size.should == 15 # FIXME: is this a bug in the API?
          searches.first.should == ['2013-09-13', 0]
        end
      end

      it 'returns search counts for a specified time range' do
        VCR.use_cassette(:analytics_searches_with_time_range) do
          searches = client.analytics_searches(engine_slug, :start_date => '2013-01-01', :end_date => '2013-01-07')
          searches.size.should == 7
          searches.first.should == ['2013-01-07', 0]
        end
      end

      it 'returns search counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_searchs_with_document_type) do
          searches = client.analytics_searches(engine_slug, :document_type_id => 'page')
          searches.size.should == 15
          searches.first.should == ['2013-09-16', 0]
        end
      end

      it 'returns search counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_searches_with_document_type_and_time_range) do
          searches = client.analytics_autoselects(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          searches.size.should == 7
          searches.first.should == ['2013-07-07', 0]
        end
      end
    end

    context '#analytics_autoselects' do
      it 'returns autoselect counts for the default time frame' do
        VCR.use_cassette(:analytics_autoselects) do
          autoselects = client.analytics_autoselects(engine_slug)
          autoselects.size.should == 15
          autoselects.first.should == ['2013-09-13', 0]
        end
      end

      it 'returns autoselects counts for a specified time range' do
        VCR.use_cassette(:analytics_autoselects_with_time_range) do
          autoselects = client.analytics_autoselects(engine_slug, :start_date => '2013-07-01', :end_date => '2013-07-07')
          autoselects.size.should == 7
        end
      end

      it 'returns autoselect counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_autoselects_with_document_type) do
          autoselects = client.analytics_autoselects(engine_slug, :document_type_id => 'page')
          autoselects.size.should == 15
        end
      end

      it 'returns autoselect counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_autoselects_with_document_type_and_time_range) do
          autoselects = client.analytics_autoselects(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          autoselects.size.should == 7
        end
      end
    end

    context '#analytics_clicks' do
      it 'returns click counts for the default time frame' do
        VCR.use_cassette(:analytics_clicks) do
          clicks = client.analytics_clicks(engine_slug)
          clicks.size.should == 15
          clicks.first.should == ['2013-09-17', 0]
        end
      end

      it 'returns clicks counts for a specified time range' do
        VCR.use_cassette(:analytics_clicks_with_time_range) do
          clicks = client.analytics_clicks(engine_slug, :start_date => '2013-07-01', :end_date => '2013-07-07')
          clicks.size.should == 7
          clicks.first.should == ['2013-07-07', 0]
        end
      end

      it 'returns click counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_clicks_with_document_type) do
          clicks = client.analytics_clicks(engine_slug, :document_type_id => 'page')
          clicks.size.should == 15
        end
      end

      it 'returns click counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_clicks_with_document_type_and_time_range) do
          clicks = client.analytics_clicks(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          clicks.size.should == 7
          clicks.first.should == ['2013-07-07', 0]
        end
      end
    end

    context '#analytics_top_queries' do
      it 'returns top queries' do
        VCR.use_cassette(:analytics_top_queries) do
          top_queries = client.analytics_top_queries(engine_slug)
          top_queries.size.should == 3
          top_queries.first.should == ['"fire watch"', 1]
        end
      end

      it 'returns top queries with pagination' do
        VCR.use_cassette(:analytics_top_queries_paginated) do
          top_queries = client.analytics_top_queries(engine_slug, :start_date => '2013-08-01', :end_date => '2013-08-30', :per_page => 5, :page => 2)
          top_queries.size.should == 5
          top_queries.first.should == ['no simple victory', 1]
        end
      end

      it 'raises an error if the timeframe is to large' do
        VCR.use_cassette(:analytics_top_queries_too_large) do
          expect do
            top_queries = client.analytics_top_queries(engine_slug, :start_date => '2013-01-01', :end_date => '2013-05-01')
          end.to raise_error(Swiftype::BadRequest)
        end
      end
    end

    context 'analytics_top_no_result_queries' do
      it 'returns top queries with no results for the default time range' do
        VCR.use_cassette(:analytics_top_no_result_queries) do
          top_no_result_queries = client.analytics_top_no_result_queries(engine_slug)
          top_no_result_queries.size.should == 2
          top_no_result_queries.first.should == ['no results', 10]
        end
      end

      it 'has top no result queries in date ranges' do
        VCR.use_cassette(:analytics_top_no_result_queries_paginated) do
          top_no_result_queries = client.analytics_top_no_result_queries(engine_slug, :start_date => '2013-08-01', :end_date => '2013-08-30', :per_page => 5, :page => 2)
          top_no_result_queries.size.should == 1
          top_no_result_queries.first.should == ['no result again', 2]
        end
      end
    end
  end

  context 'Domain' do
    let(:engine_slug) { 'crawler-demo-site' }
    let(:domain_id) { '51534c6e2ed960cc79000001' }

    it 'gets all domains' do
      VCR.use_cassette(:list_domains) do
        domains = client.domains(engine_slug)
        domains.size.should == 1
        domains.first['id'].should == domain_id
      end
    end

    context '#domain' do
      it 'shows a domain if it exists' do
        VCR.use_cassette(:find_domain) do
          domain = client.domain(engine_slug, domain_id)
          domain['id'].should == domain_id
        end
      end

      it 'raises an error if the domain does not exist' do
        VCR.use_cassette(:find_domain_failure) do
          expect do
            domain = client.domain(engine_slug, 'bogus')
          end.to raise_error(Swiftype::NonExistentRecord)
        end
      end
    end

    context '#create_domain' do
      it 'creates a domain' do
        VCR.use_cassette(:create_domain) do
          url = 'http://www.zombo.com/'
          domain = client.create_domain(engine_slug, url)
          domain['submitted_url'].should == url
        end
      end
    end

    it 'destroys a domain' do
      VCR.use_cassette(:destroy_domain) do
        response = client.destroy_domain(engine_slug, '52324b132ed960589800004a')
        response.should be_nil
      end
    end

    context '#recrawl_domain' do
      it 'enqueues a request to recrawl a domain' do
        VCR.use_cassette(:recrawl_domain_success) do
          domain = client.recrawl_domain(engine_slug, domain_id)
          domain['id'].should == domain_id
        end
      end

      it 'raises an exception if domain recrawl is not allowed' do
        VCR.use_cassette(:recrawl_domain_failure) do
          expect do
            domain = client.recrawl_domain(engine_slug, domain_id)
          end.to raise_error(Swiftype::Forbidden)
        end
      end
    end

    context '#crawl_url' do
      it 'enqueues a request to crawl a URL on a domain' do
        VCR.use_cassette(:crawl_url) do
          url = 'http://crawler-demo-site.herokuapp.com/2012/01/01/first-post.html'
          crawled_url = client.crawl_url(engine_slug, domain_id, url)
          crawled_url['url'].should == url
        end
      end
    end
  end

  context 'Clickthrough' do
    let(:query) { 'foo' }
    let(:document_type_slug) { 'videos' }
    let(:external_id) { 'FtX8nswnUKU'}

    context "#log_clickthough" do
      # Not thrilled with this test, but since nothing is returned all we
      # can reasonably check is that an error isn't raised
      it 'returns nil' do
        VCR.use_cassette(:log_clickthrough_success) do
          response = client.log_clickthrough(engine_slug, document_type_slug, query, external_id)
          response.should == nil
        end
      end

      it 'raises an error when missing params' do
        VCR.use_cassette(:log_clickthrough_failure) do
          expect do
            client.log_clickthrough(engine_slug, document_type_slug, nil, external_id)
          end.to raise_error(Swiftype::BadRequest)
        end
      end
    end
  end
end
