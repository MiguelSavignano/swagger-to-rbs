require 'json'
require 'pry'
require_relative '../lib/swagger2_rbs/rest_endpoint'

describe 'Swagger2Rbs::RestEndpoint' do

  let(:swagger_spec) { JSON.parse(File.read('spec/fixtures/swagger.json')) }

  describe 'example path /oauth/token' do
    let(:path_method) { ["/oauth/token", "post"] }
    let(:subject) {
      path_props = swagger_spec.dig("paths", path_method[0], path_method[1])
      Swagger2Rbs::RestEndpoint.new(path_method[0], path_method[1], path_props)
    }

    it '#method_name' do
      expect(subject.method_name).to eq("get_access_token")
    end

    describe "#path_with_parameters" do
      describe 'path /oauth/token' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.path_with_parameters).to eq("/oauth/token") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.path_with_parameters).to eq("/accounts/\\\#{id}") }
      end
    end

    describe "#parameters_for_method" do
      describe 'path /oauth/token' do
        it { expect(subject.parameters_for_method).to eq("body, options = {}") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.parameters_for_method).to eq("id, params = {}, options = {}") }
      end
    end

    describe "#parameters_typed" do
      describe 'path /oauth/token' do
        it { expect(subject.parameters_typed).to eq(nil) }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.parameters_typed).to eq("String id, ?Hash[String, String] params, ?Hash[untyped, untyped] options") }
      end
    end

    describe "#body" do
      describe 'path /accounts/{id}/contacts array of object' do
        let(:path_method) { ["/accounts/{id}/contacts", "post"] }
        it { expect(subject.body["contact_numbers"]).to eq([{"number"=>"String", "type"=>"String"}]) }
      end
    end

    describe "#body_typed" do
      describe 'path /oauth/token' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.body_typed).to eq("{grant_type: String, client_id: String, client_secret: String, scope: String} body, ?Hash[untyped, untyped] options") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.body_typed).to eq(nil) }
      end

      describe 'path /accounts/{id}/contacts array of object' do
        let(:path_method) { ["/accounts/{id}/contacts", "post"] }
        it do
          expect(subject.body_typed)
            .to eq("{account_id: String, relationship: String, first_name: String, last_name: String, email: String, communications_opt_out: String, contact_numbers: Array[{type: String, number: String}]} body, ?Hash[untyped, untyped] options")
        end
      end

      describe 'path /certificates array of string' do
        let(:path_method) { ["/certificates", "post"] }
        it do
          expect(subject.body_typed)
            .to eq("{type: String, policy_ids: Array[String], fields: {holder_name: String}} body, ?Hash[untyped, untyped] options")
        end
      end
    end
  end
end