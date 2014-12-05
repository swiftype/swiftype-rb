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
          expect(results.document_types.size).to eq(2)
          expect(results['videos'].size).to eq(2)
          expect(results['channels'].size).to eq(1)
        end
      end

      it 'searches the engine with options' do
        VCR.use_cassette(:engine_search_pagination) do
          results = client.search(engine_slug, 'cat', {:page => 2})
          expect(results.document_types.size).to eq(2)
          expect(results['videos'].size).to eq(0)
          expect(results['channels'].size).to eq(0)
        end
      end

      it 'includes facets when requested' do
        VCR.use_cassette(:engine_search_facets) do
          results = client.search(engine_slug, nil, {:facets => {:videos => ['category_id']}})
          expect(results.document_types.size).to eq(2)
          expect(results.facets('channels')).to be_empty
          expect(results.facets('videos')['category_id']).to eq({
            "23" => 4,
            "28" => 2,
            "15" => 2,
            "25" => 1,
            "22" => 1,
            "2" => 1,
            "10" => 1
          })
        end
      end
    end

    context '#search_document_type' do
      let(:document_type_slug) { 'videos' }

      it 'searches only the provided DocumentType' do
        VCR.use_cassette(:document_type_search) do
          results = client.search_document_type(engine_slug, document_type_slug, 'cat')
          expect(results.document_types).to eq(['videos'])
          expect(results['videos'].size).to eq(2)
        end
      end

      it 'searches the DocumentType with options' do
        VCR.use_cassette(:document_type_search_pagination) do
          results = client.search_document_type(engine_slug, document_type_slug, 'cat', {:page => 2})
          expect(results.document_types).to eq(['videos'])
          expect(results[document_type_slug].size).to eq(0)
        end
      end
    end
  end

  context 'Options' do
    let(:options_client) { Swiftype::Client.new(options) }

    context '#request' do
      let(:options) { { :open_timeout => 3 } }
      it 'respects the Net::HTTP open_timeout option' do
        expect(options_client.open_timeout).to eq(3)
      end
    end
  end

  context 'Suggest' do
    context '#suggest' do
      it 'does prefix searches for all DocumentTypes in the engine' do
        VCR.use_cassette(:engine_suggest) do
          results = client.suggest(engine_slug, 'goo')
          expect(results.document_types.size).to eq(2)
          expect(results['videos'].size).to eq(1)
          expect(results['channels'].size).to eq(1)
        end
      end

      it 'suggests for an engine with options' do
        VCR.use_cassette(:engine_suggest_pagination) do
          results = client.suggest(engine_slug, 'goo', {:page => 2})
          expect(results.document_types.size).to eq(2)
          expect(results['videos'].size).to eq(0)
          expect(results['channels'].size).to eq(0)
        end
      end
    end

    context '#suggest_document_type' do
      let(:document_type_slug) { 'videos' }

      it 'does a prefix search on the provided DocumentType' do
        VCR.use_cassette(:document_type_suggest) do
          results = client.suggest_document_type(engine_slug, document_type_slug, 'goo')
          expect(results.document_types).to eq(['videos'])
          expect(results['videos'].size).to eq(1)
        end
      end

      it 'suggests for a document types with options' do
        VCR.use_cassette(:document_type_suggest_pagination) do
          results = client.suggest_document_type(engine_slug, document_type_slug, 'goo', {:page => 2})
          expect(results.document_types).to eq(['videos'])
          expect(results[document_type_slug].size).to eq(0)
        end
      end
    end
  end


  context 'Engine' do
    it 'gets all engines' do
      VCR.use_cassette(:list_engines) do
        engines = client.engines
        expect(engines.size).to eq(6)
      end
    end

    it 'gets an engine' do
      VCR.use_cassette(:find_engine) do
        engine = client.engine(engine_slug)
        expect(engine['slug']).to eq(engine_slug)
      end
    end

    it 'creates engines' do
      VCR.use_cassette(:create_engine) do
        engine = client.create_engine('new engine from spec')
        expect(engine['slug']).to eq('new-engine-from-spec')
      end
    end

    it 'destroys engines' do
      VCR.use_cassette(:destroy_engine) do
        response = client.destroy_engine('new-engine-from-spec')
        expect(response).to be_nil
      end
    end
  end

  context 'DocumentType' do
    let(:document_type_slug) { 'videos' }

    it 'gets all document types' do
      VCR.use_cassette(:list_document_type) do
        document_types = client.document_types(engine_slug)
        expect(document_types.size).to eq(2)
        expect(document_types.map { |dt| dt['name'] }.sort).to eq(['channels', 'videos'])
      end
    end

    it 'gets a document type' do
      VCR.use_cassette(:find_document_type) do
        document_type = client.document_type(engine_slug, document_type_slug)
        expect(document_type['slug']).to eq(document_type_slug)
      end
    end

    it 'creates a document type' do
      VCR.use_cassette(:create_document_type) do
        name = document_type_slug
        document_type = client.create_document_type(engine_slug, 'new_doc_type')
        expect(document_type['name']).to eq('new_doc_type')
        expect(document_type['slug']).to eq('new-doc-type')
      end
    end

    it 'destroys document types' do
      VCR.use_cassette(:destroy_document_type) do
        response = client.destroy_document_type(engine_slug, 'new-doc-type')
        expect(response).to be_nil
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
    before :each do
      def check_async_response_format(response, options = {})
        expect(response.keys).to match_array(["document_receipts", "batch_link"])
        expect(response["document_receipts"]).to be_a_kind_of(Array)
        expect(response["document_receipts"].first.keys).to match_array(["id", "external_id", "link", "status", "errors"])
        expect(response["document_receipts"].first["external_id"]).to eq(options[:external_id]) if options[:external_id]
        expect(response["document_receipts"].first["status"]).to eq(options[:status]) if options[:status]
        expect(response["document_receipts"].first["errors"]).to eq(options[:errors]) if options[:errors]
      end
    end

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
        expect(documents.size).to eq(2)
      end
    end

    it 'lists documents with pagination' do
      VCR.use_cassette(:list_documents_with_pagination) do
        documents = client.documents(engine_slug, document_type_slug, 2, 2)
        expect(documents.size).to eq(2)
      end
    end

    it 'find a document' do
      VCR.use_cassette(:find_document) do
        document = client.document(engine_slug, document_type_slug, document_id)
        expect(document['external_id']).to eq(document_id)
      end
    end

    it 'creates a document' do
      VCR.use_cassette(:create_document) do
        document = client.create_document(engine_slug, document_type_slug, documents.first)
        expect(document['external_id']).to eq('INscMGmhmX4')
      end
    end

    it 'bulk create multiple documents' do
      VCR.use_cassette(:bulk_create_documents) do
        response = client.create_documents(engine_slug, document_type_slug, documents)
        expect(response).to eq([true, true])
      end
    end

    it 'destroys a document' do
      VCR.use_cassette(:destroy_document) do
        response = client.destroy_document(engine_slug, document_type_slug, 'INscMGmhmX4')
        expect(response).to be_nil
      end
    end

    it 'destroys multiple documents' do
      VCR.use_cassette(:bulk_destroy_documents) do
        response = client.destroy_documents(engine_slug, document_type_slug, ['INscMGmhmX4', 'XfY9Dsg_DZk'])
        expect(response).to eq([true, true])
      end
    end

    context '#create_or_update_document' do
      it 'creates a document' do
        VCR.use_cassette(:create_or_update_document_create) do
          response = client.create_or_update_document(engine_slug, document_type_slug, {:external_id => 'foobar', :fields => [{:type => :string, :name => 'title', :value => 'new document'}]})
          expect(response['external_id']).to eq('foobar')
          expect(response['title']).to eq('new document')
        end
      end

      it 'updates an existing document' do
        VCR.use_cassette(:create_or_update_document_update) do
          response = client.create_or_update_document(engine_slug, document_type_slug, {:external_id => document_id, :fields => [{:type => :string, :name => 'title', :value => 'new title'}]})
          expect(response['external_id']).to eq(document_id)
          expect(response['title']).to eq('new title')
        end
      end
    end

    context '#bulk_create_or_update_documents' do
      it 'returns true for all documents successfully created or updated' do
        VCR.use_cassette(:bulk_create_or_update_documents_success) do
          response = client.create_or_update_documents(engine_slug, document_type_slug, documents)
          expect(response).to eq([true, true])
        end
      end

      it 'returns false if a document cannot be created or updated due to an error' do
        documents = [{:external_id => 'failed_doc', :fields => [{:type => :string, :name => :title}]}] # missing value

        VCR.use_cassette(:bulk_create_or_update_documents_failure) do
          response = client.create_or_update_documents(engine_slug, document_type_slug, documents)
          expect(response).to eq([false])
        end
      end
    end

    context '#async_create_or_update_documents' do
      it 'returns true for all documents successfully created or updated' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          response = client.async_create_or_update_documents(engine_slug, document_type_slug, documents)
          check_async_response_format(response, :external_id => documents.first["external_id"], :status => "pending")
        end
      end

      it 'returns false if a document cannot be created or updated due to an error' do
        documents = [{:external_id => 'failed_doc', :fields => [{:type => :string, :name => :title}]}] # missing value

        VCR.use_cassette(:async_create_or_update_document_failure) do
          response = client.async_create_or_update_documents(engine_slug, document_type_slug, documents)
          check_async_response_format(response, :external_id => documents.first["external_id"], :status => "failed", :errors => ["Missing required parameter: value"])
        end
      end
    end

    context '#document_receipts' do
      before :each do
        def get_receipt_ids
          receipt_ids = nil
          VCR.use_cassette(:async_create_or_update_document_success) do
            response = client.async_create_or_update_documents(engine_slug, document_type_slug, documents)
            receipt_ids = response["document_receipts"].map { |r| r["id"] }
          end
          receipt_ids
        end
      end

      it 'returns hash with one receipt' do
        VCR.use_cassette(:document_receipts_single) do
          receipt_ids = get_receipt_ids
          response = client.document_receipts(receipt_ids.first)
          expect(response).to eq("id" => receipt_ids.first, "status" => "pending")
        end
      end

      it 'returns array of hashes one for each receipt' do
        VCR.use_cassette(:document_receipts_multiple) do
          receipt_ids = get_receipt_ids
          response = client.document_receipts(receipt_ids)
          expect(response).to eq([{"id" => receipt_ids[0], "status" => "pending"}, {"id" => receipt_ids[1], "status" => "pending"}])
        end
      end
    end

    context '#index_documents' do
      it 'returns #async_create_or_update_documents format return when async has been passed as true' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          response = client.index_documents(engine_slug, document_type_slug, documents, :async => true)
          check_async_response_format(response, :external_id => documents.first["external_id"], :status => "pending")
        end
      end

      it 'returns document_receipts when successfull' do
        VCR.use_cassette(:async_create_or_update_document_success) do
          VCR.use_cassette(:document_receipts_multiple_complete) do
            response = client.index_documents(engine_slug, document_type_slug, documents)
            expect(response.map(&:keys)).to eq([["id", "status", "link"], ["id", "status", "link"]])
            expect(response.map { |a| a["status"] }).to eq(["complete", "complete"])
          end
        end
      end

      it 'should timeout if the process takes longer than the timeout option passed' do
        client.stub(:document_receipts){ sleep 1}
        VCR.use_cassette(:async_create_or_update_document_success) do
          expect {
            client.index_documents(engine_slug, document_type_slug, documents, :timeout => 0.5)
          }.to raise_error Timeout::Error
        end
      end
    end

    context '#bulk_create_or_update_documents_verbose' do
      it 'returns true for all documents successfully created or updated' do
        VCR.use_cassette(:bulk_create_or_update_documents_verbose_success) do
          response = client.create_or_update_documents_verbose(engine_slug, document_type_slug, documents)
          expect(response).to eq([true, true])
        end
      end

      it 'returns a descriptive error message if a document cannot be created or updated due to an error' do
        documents = [{:external_id => 'failed_doc', :fields => [{:type => :string, :name => :title}]}] # missing value

        VCR.use_cassette(:bulk_create_or_update_documents_verbose_failure) do
          response = client.create_or_update_documents_verbose(engine_slug, document_type_slug, documents)
          expect(response.size).to eq(1)
          expect(response.first).to match /^Invalid field definition/
        end
      end
    end

    context '#update_document' do
      it 'updates a document given its id and fields to update' do
        fields = {:title => 'awesome new title', :channel_id => 'UC5VA5j05FjETg-iLekcyiBw'}
        VCR.use_cassette(:update_document) do
          response = client.update_document(engine_slug, document_type_slug, document_id, fields)
          expect(response['external_id']).to eq(document_id)
          expect(response['title']).to eq('awesome new title')
          expect(response['channel_id']).to eq('UC5VA5j05FjETg-iLekcyiBw')
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
          expect(response).to eq([true, true])
        end
      end

      it 'returns false if document is not successfully updated' do
        documents = [{:external_id => 'not_there', :fields => [{:name => :title, :value => 'hi', :type => :string}]}]

        VCR.use_cassette(:update_documents_failure_non_existent_document) do
          response = client.update_documents(engine_slug, document_type_slug, documents)
          expect(response).to eq([false])
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
          expect(searches.size).to eq(15) # FIXME: is this a bug in the API?
          expect(searches.first).to eq(['2013-09-13', 0])
        end
      end

      it 'returns search counts for a specified time range' do
        VCR.use_cassette(:analytics_searches_with_time_range) do
          searches = client.analytics_searches(engine_slug, :start_date => '2013-01-01', :end_date => '2013-01-07')
          expect(searches.size).to eq(7)
          expect(searches.first).to eq(['2013-01-07', 0])
        end
      end

      it 'returns search counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_searchs_with_document_type) do
          searches = client.analytics_searches(engine_slug, :document_type_id => 'page')
          expect(searches.size).to eq(15)
          expect(searches.first).to eq(['2013-09-16', 0])
        end
      end

      it 'returns search counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_searches_with_document_type_and_time_range) do
          searches = client.analytics_autoselects(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          expect(searches.size).to eq(7)
          expect(searches.first).to eq(['2013-07-07', 0])
        end
      end
    end

    context '#analytics_autoselects' do
      it 'returns autoselect counts for the default time frame' do
        VCR.use_cassette(:analytics_autoselects) do
          autoselects = client.analytics_autoselects(engine_slug)
          expect(autoselects.size).to eq(15)
          expect(autoselects.first).to eq(['2013-09-13', 0])
        end
      end

      it 'returns autoselects counts for a specified time range' do
        VCR.use_cassette(:analytics_autoselects_with_time_range) do
          autoselects = client.analytics_autoselects(engine_slug, :start_date => '2013-07-01', :end_date => '2013-07-07')
          expect(autoselects.size).to eq(7)
        end
      end

      it 'returns autoselect counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_autoselects_with_document_type) do
          autoselects = client.analytics_autoselects(engine_slug, :document_type_id => 'page')
          expect(autoselects.size).to eq(15)
        end
      end

      it 'returns autoselect counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_autoselects_with_document_type_and_time_range) do
          autoselects = client.analytics_autoselects(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          expect(autoselects.size).to eq(7)
        end
      end
    end

    context '#analytics_clicks' do
      it 'returns click counts for the default time frame' do
        VCR.use_cassette(:analytics_clicks) do
          clicks = client.analytics_clicks(engine_slug)
          expect(clicks.size).to eq(15)
          expect(clicks.first).to eq(['2013-09-17', 0])
        end
      end

      it 'returns clicks counts for a specified time range' do
        VCR.use_cassette(:analytics_clicks_with_time_range) do
          clicks = client.analytics_clicks(engine_slug, :start_date => '2013-07-01', :end_date => '2013-07-07')
          expect(clicks.size).to eq(7)
          expect(clicks.first).to eq(['2013-07-07', 0])
        end
      end

      it 'returns click counts for a specified DocumentType' do
        VCR.use_cassette(:analytics_clicks_with_document_type) do
          clicks = client.analytics_clicks(engine_slug, :document_type_id => 'page')
          expect(clicks.size).to eq(15)
        end
      end

      it 'returns click counts for a specified DocumentType and time range' do
        VCR.use_cassette(:analytics_clicks_with_document_type_and_time_range) do
          clicks = client.analytics_clicks(engine_slug, :document_type_id => 'page', :start_date => '2013-07-01', :end_date => '2013-07-07')
          expect(clicks.size).to eq(7)
          expect(clicks.first).to eq(['2013-07-07', 0])
        end
      end
    end

    context '#analytics_top_queries' do
      it 'returns top queries' do
        VCR.use_cassette(:analytics_top_queries) do
          top_queries = client.analytics_top_queries(engine_slug)
          expect(top_queries.size).to eq(3)
          expect(top_queries.first).to eq(['"fire watch"', 1])
        end
      end

      it 'returns top queries with pagination' do
        VCR.use_cassette(:analytics_top_queries_paginated) do
          top_queries = client.analytics_top_queries(engine_slug, :start_date => '2013-08-01', :end_date => '2013-08-30', :per_page => 5, :page => 2)
          expect(top_queries.size).to eq(5)
          expect(top_queries.first).to eq(['no simple victory', 1])
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
          expect(top_no_result_queries.size).to eq(2)
          expect(top_no_result_queries.first).to eq(['no results', 10])
        end
      end

      it 'has top no result queries in date ranges' do
        VCR.use_cassette(:analytics_top_no_result_queries_paginated) do
          top_no_result_queries = client.analytics_top_no_result_queries(engine_slug, :start_date => '2013-08-01', :end_date => '2013-08-30', :per_page => 5, :page => 2)
          expect(top_no_result_queries.size).to eq(1)
          expect(top_no_result_queries.first).to eq(['no result again', 2])
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
        expect(domains.size).to eq(1)
        expect(domains.first['id']).to eq(domain_id)
      end
    end

    context '#domain' do
      it 'shows a domain if it exists' do
        VCR.use_cassette(:find_domain) do
          domain = client.domain(engine_slug, domain_id)
          expect(domain['id']).to eq(domain_id)
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
          expect(domain['submitted_url']).to eq(url)
        end
      end
    end

    it 'destroys a domain' do
      VCR.use_cassette(:destroy_domain) do
        response = client.destroy_domain(engine_slug, '52324b132ed960589800004a')
        expect(response).to be_nil
      end
    end

    context '#recrawl_domain' do
      it 'enqueues a request to recrawl a domain' do
        VCR.use_cassette(:recrawl_domain_success) do
          domain = client.recrawl_domain(engine_slug, domain_id)
          expect(domain['id']).to eq(domain_id)
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
          expect(crawled_url['url']).to eq(url)
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
          expect(response).to eq(nil)
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
