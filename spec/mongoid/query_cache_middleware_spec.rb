# frozen_string_literal: true

require "spec_helper"

describe Mongoid::QueryCache::Middleware do

  let :middleware do
    Mongoid::QueryCache::Middleware.new(app)
  end

  context "when not touching mongoid on the app" do

    let(:app) do
      ->(env) { @enabled = Mongoid::QueryCache.enabled?; [200, env, "app"] }
    end

    it "returns success" do
      code, _ = middleware.call({})
      expect(code).to eq(200)
    end

    it "enables the query cache" do
      middleware.call({})
      expect(@enabled).to be true
    end
  end

  context "when querying on the app" do

    let(:app) do
      ->(env) {
        Band.all.to_a
        [200, env, "app"]
      }
    end

    it "returns success" do
      code, _ = middleware.call({})
      expect(code).to eq(200)
    end

    context 'with driver query cache' do
      min_driver_version '2.14'

      it "cleans the query cache after it responds" do
        middleware.call({})
        expect(Mongo::QueryCache.send(:cache_table)).to be_empty
      end
    end

    context 'with mongoid query cache' do
      max_driver_version '2.13'

      it "cleans the query cache after it responds" do
        middleware.call({})
        expect(Mongoid::QueryCache.cache_table).to be_empty
      end
    end
  end

  context 'when driver implements query cache middleware' do
    min_driver_version '2.15'

    it 'uses the driver query cache middleware' do
      Mongoid::QueryCache::Middleware.should be Mongo::QueryCache::Middleware
    end
  end
end
