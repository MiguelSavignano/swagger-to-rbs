require 'json'
require 'pry'
require_relative '../lib/swagger2_rbs'

describe 'Swagger2Rbs' do

  let(:swagger_spec) { JSON.parse(File.read('spec/fixtures/swagger.json')) }

  describe '.resolve_ref' do
    it "resolve $ref requestBody" do
      result = Swagger2Rbs.resolve_all_ref(swagger_spec)
      expect(result.dig("paths", "/pet", "put", "requestBody", "content", "application/json", "schema"))
      .to eq(swagger_spec["components"]["schemas"]["Pet"])
    end
  end
end
