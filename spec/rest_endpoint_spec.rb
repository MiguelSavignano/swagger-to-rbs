require 'json'
require 'pry'
require_relative '../lib/swagger2_rbs'

SPEC = Swagger2Rbs.resolve_all_ref(JSON.parse(File.read('spec/fixtures/swagger.json')))
describe 'Swagger2Rbs::RestEndpoint' do

  let(:swagger_spec) { SPEC }

  describe 'example path /oauth/token' do
    let(:path_method) { ["/oauth/token", "post"] }
    let(:subject) {
      path_props = swagger_spec.dig("paths", path_method[0], path_method[1])
      Swagger2Rbs::RestEndpoint.new(path_method[0], path_method[1], path_props)
    }

    it '#method_name' do
      expect(subject.method_name).to eq('get_access_token')
    end

    describe "#path_with_parameters" do
      describe 'path /oauth/token' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.path_with_parameters).to eq('/oauth/token') }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.path_with_parameters).to eq('/accounts/#{id}') }
      end
    end

    describe "#response_typed" do
      describe 'path /oauth/token 200' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.response_typed("200")).to eq('{ "access_token" => String, "token_type" => String, "expires_in" => Integer, "scope" => String, "created_at" => Integer }') }
      end

      describe 'path /accounts/{id} 200' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.response_typed("200")).to eq('{ "data" => {"id" => String, "external_id" => String, "business_information" => {"name" => String, "type" => String, "website" => String, "identification_number" => String, "year_established" => Number, "annual_revenue" => {"value" => Number, "amount" => Number, "currency" => String}, "fulltime_employees" => Integer, "parttime_employees" => Integer}, "industry" => {"type" => String, "class_code" => String, "subclass_code" => String}, "addresses" => Array[{"type" => String, "address_line" => String, "city" => String, "state" => String, "country_code" => String, "postal_code" => String}], "email" => String, "phone_number" => String} }') }
      end

      describe 'path /accounts/{id} 404' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.response_typed("404")).to eq('{ "errors" => Array[{"source" => String, "type" => String, "message" => String}] }') }
      end
    end

    describe "#all_responses_typed" do
      describe 'path /accounts/{id} 200' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.all_responses_typed).to eq('{ "200" => {"data" => {"id" => String, "external_id" => String, "business_information" => {"name" => String, "type" => String, "website" => String, "identification_number" => String, "year_established" => Number, "annual_revenue" => {"value" => Number, "amount" => Number, "currency" => String}, "fulltime_employees" => Integer, "parttime_employees" => Integer}, "industry" => {"type" => String, "class_code" => String, "subclass_code" => String}, "addresses" => Array[{"type" => String, "address_line" => String, "city" => String, "state" => String, "country_code" => String, "postal_code" => String}], "email" => String, "phone_number" => String}}, "404" => {"errors" => Array[{"source" => String, "type" => String, "message" => String}]} }') }
      end
    end

    describe "#parameters_for_method" do
      describe 'path /oauth/token' do
        it { expect(subject.parameters_for_method).to eq('body, options = {}') }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.parameters_for_method).to eq('id, options = {}') }
      end

      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it { expect(subject.parameters_for_method).to eq('petId, options = {}') }
      end
    end

    describe "#typed_parameters_for_method" do
      describe 'path /oauth/token' do
        it { expect(subject.typed_parameters_for_method).to eq('({ "grant_type" => String, "client_id" => String, "client_secret" => String, "scope" => String } body, ?Hash[untyped, untyped] options)') }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.typed_parameters_for_method).to eq('(String id, ?Hash[untyped, untyped] options)') }
      end

      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it { expect(subject.typed_parameters_for_method).to eq('(String petId, ?Hash[untyped, untyped] options)') }
      end

      describe 'path /user/{username}' do
        let(:path_method) { ["/user/{username}", "put"] }
        it { expect(subject.typed_parameters_for_method).to eq('(String username, { "id" => Integer, "username" => String, "firstName" => String, "lastName" => String, "email" => String, "password" => String, "phone" => String, "userStatus" => Integer } body, ?Hash[untyped, untyped] options)') }
      end
    end

    describe 'to_yaml' do
      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it "" do
          result = subject.to_yaml
          expect(result[:method_name]).to eq('deletePet')
          expect(result[:path_parameters]).to eq(["petId"])
          expect(result[:body]).to eq({})
        end
      end

      describe 'path /pet' do
        let(:path_method) { ["/pet", "put"] }
        it "to_yaml" do
          result = subject.to_yaml
          expect(result[:method_name]).to eq('updatePet')
          expect(result[:path_parameters]).to eq([])
          expect(result[:body]).to eq({"id"=>"integer", "name"=>"string", "category"=>{"id"=>"integer", "name"=>"string"}, "photoUrls"=>["string"], "tags"=>[{"id"=>"integer", "name"=>"string"}], "status"=>"string"})
        end
      end
    end

    describe "#body" do
      describe 'path /accounts/{id}/contacts array of object' do
        let(:path_method) { ["/accounts/{id}/contacts", "post"] }
        it { expect(subject.body["contact_numbers"]).to eq([{"number"=>"string", "type"=>"string"}]) }
      end

      describe 'path /user/createWithList array first object' do
        let(:path_method) { ["/user/createWithList", "post"] }
        it { expect(subject.body).to eq([{"email"=>"string", "firstName"=>"string", "id"=>"integer", "lastName"=>"string", "password"=>"string", "phone"=>"string", "userStatus"=>"integer", "username"=>"string"}]) }
      end
    end

    describe "#body_typed" do
      describe 'path /oauth/token' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.body_typed).to eq('{ "grant_type" => String, "client_id" => String, "client_secret" => String, "scope" => String }') }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.body_typed).to eq(nil) }
      end

      describe 'path /accounts/{id}/contacts array of object' do
        let(:path_method) { ["/accounts/{id}/contacts", "post"] }
        it do
          expect(subject.body_typed)
            .to eq('{ "account_id" => String, "relationship" => String, "first_name" => String, "last_name" => String, "email" => String, "communications_opt_out" => String, "contact_numbers" => Array[{"type" => String, "number" => String}] }')
        end
      end

      describe 'path /data/v1/policy object of object' do
        let(:path_method) { ["/data/v1/policy", "post"] }
        it do
          expect(subject.body_typed)
          .to eq('{ "payloads" => Array[{"identifier" => {"externalIdField" => String, "value" => String}, "data" => {"Account" => {"UUID" => String}, "InsuranceType" => String}}] }')
        end
      end

      describe 'path /certificates array of string' do
        let(:path_method) { ["/certificates", "post"] }
        it do
          expect(subject.body_typed)
            .to eq('{ "type" => String, "policy_ids" => Array[String], "fields" => {"holder_name" => String} }')
        end
      end
    end
  end
end
