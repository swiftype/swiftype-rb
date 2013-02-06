require 'spec_helper'

describe Swiftype::Easy do
  let(:engine_id) { 'engine' }
  let(:document_type_id) { 'document_type' }

  before :each do
    Swiftype::Easy.configure do |config|
      config.endpoint = ENV['API_HOST'] || config.endpoint
      config.api_key = 'dummy'
    end

    @client = Swiftype::Easy.new
  end

  context 'Engine' do
    it 'gets all engines' do
      engines = @client.engines
      engines.size.should == 2
    end

    it 'gets an engine' do
      engine = @client.engine(engine_id)
      engine['slug'].should == engine_id
    end

    it 'creates engines' do
      engine = @client.create_engine(engine_id)
      engine['slug'].should == engine_id
    end

    it 'destroys engines' do
      @client.destroy_engine(engine_id)
    end

    it 'searches the engine' do
      results = @client.search(engine_id, '*')
      results.size.should == 2
    end

    it 'searches the engine with options' do
      results = @client.search(engine_id, '*', {:page => 2})
      results.size.should == 2
    end

    it 'suggests for an engine' do
      results = @client.suggest(engine_id, '*')
      results.size.should == 2
    end

    it 'suggests for an engine with options' do
      results = @client.suggest(engine_id, '*', {:page => 2})
      results.size.should == 2
    end
end

  context 'DocumentType' do
    it 'gets all document types' do
      document_types = @client.document_types(engine_id)
      document_types.size.should == 2
    end

    it 'gets a document type' do
      document_type = @client.document_type(engine_id, document_type_id)
      document_type['slug'].should == document_type_id
    end

    it 'creates a document type' do
      name = document_type_id
      document_type = @client.create_document_type(engine_id, name)
      document_type['name'].should == name
    end

    it 'destroys document types' do
      @client.destroy_document_type(engine_id, document_type_id)
    end

    it 'searches document types' do
      results = @client.search_document_type(engine_id, document_type_id, '*')
      results.should include(document_type_id)
      results.size.should == 1
    end

    it 'searches document types with options' do
      results = @client.search_document_type(engine_id, document_type_id, '*', {:page => 2})
      results.should include(document_type_id)
      results.size.should == 1
    end

    it 'suggests for a document types' do
      results = @client.suggest_document_type(engine_id, document_type_id, '*')
      results.should include(document_type_id)
      results.size.should == 1
    end

    it 'suggests for a document types with options' do
      results = @client.suggest_document_type(engine_id, document_type_id, '*', {:page => 2})
      results.should include(document_type_id)
      results.size.should == 1
    end
  end

  context 'Document' do
    let(:document_id) { 'doc_id'}
    let(:simple_documents) { ['doc_id1', 'doc_id2'].map { |id| {:external_id => id} } }

    it 'gets all documents' do
      documents = @client.documents(engine_id, document_type_id)
      documents.size.should == 2
    end

    it 'paginations documents' do
      documents = @client.documents(engine_id, document_type_id, 2, 10)
      documents.size.should == 2
    end

    it 'shows a document' do
      document = @client.document(engine_id, document_type_id, document_id)
      document['external_id'].should == document_id
    end

    it 'creates a document' do
      external_id = '1'
      document = @client.create_document(engine_id, document_type_id, {:external_id => external_id})
      document['external_id'].should == external_id
    end

    it 'creates multiple documents' do
      stati = @client.create_documents(engine_id, document_type_id, simple_documents)
      stati.should == simple_documents.map { |_| true }
    end

    it 'destroys a document' do
      @client.destroy_document(engine_id, document_type_id, document_id)
    end

    it 'destroys multiple documents' do
      document_ids = ['1', '2']
      stati = @client.destroy_documents(engine_id, document_type_id, document_ids)
      stati.should == document_ids.map { |_| true }
    end

    it 'creates or updates a document' do
      document = @client.create_or_update_document(engine_id, document_type_id, {:external_id => document_id, :fields => {}})
      document['external_id'].should == document_id
    end

    it 'creates or updates multiple documents' do
      stati = @client.create_or_update_documents(engine_id, document_type_id, simple_documents)
      stati.should == simple_documents.map { |_| true }
    end

    it 'updates a document' do
      fields = {:title => 'title'}
      document = @client.update_document(engine_id, document_type_id, document_id, fields)
      document['id'].should == document_id
    end

    it 'updates multiple documents' do
      stati = @client.update_documents(engine_id, document_type_id, simple_documents)
      stati.should == simple_documents.map { |_| true }
    end
  end

  context 'Analytics' do
    it 'has searches' do
      searches = @client.analytics_searches(engine_id)
      searches.size.should == 1
    end

    it 'has searches in ranges' do
      searches = @client.analytics_searches(engine_id, Time.now, Time.now)
      searches.size.should == 0
    end

    it 'has autoselects' do
      autoselects = @client.analytics_autoselects(engine_id)
      autoselects.size.should == 1
    end

    it 'has autoselects in ranges' do
      autoselects = @client.analytics_autoselects(engine_id, Time.now, Time.now)
      autoselects.size.should == 0
    end

    it 'has top queries' do
      top_queries = @client.analytics_top_queries(engine_id)
      top_queries.size.should == 2
    end

    it 'has top queries pagination' do
      top_queries = @client.analytics_top_queries(engine_id, 2, 10)
      top_queries.size.should == 0
    end
  end

  context 'Domain' do
    let(:domain_id) { 'domain_id'}

    it 'gets all domains' do
      domains = @client.domains(engine_id)
      domains.size.should == 2
    end

    it 'shows a domain' do
      domain = @client.domain(engine_id, domain_id)
      domain['id'].should == domain_id
    end

    it 'creates a domain' do
      url = 'http://www.example.com'
      domain = @client.create_domain(engine_id, url)
      domain['submitted_url'].should == url
    end

    it 'destroys a domain' do
      @client.destroy_domain(engine_id, domain_id)
    end

    it 'recrawl a domain' do
      domain = @client.recrawl_domain(engine_id, domain_id)
      domain['id'].should == domain_id
    end

    it 'crawls a url on a domain' do
      url = 'http://www.example.com'
      crawled_url = @client.crawl_url(engine_id, domain_id, url)['url']
      crawled_url.should == url
    end
  end
end
