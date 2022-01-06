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
      expect(subject.method_name).to eq("get_access_token")
    end

    describe "#path_with_parameters" do
      describe 'path /oauth/token' do
        let(:path_method) { ["/oauth/token", "post"] }
        it { expect(subject.path_with_parameters).to eq("/oauth/token") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.path_with_parameters).to eq("/accounts/\#{id}") }
      end
    end

    describe "#parameters_for_method" do
      describe 'path /oauth/token' do
        it { expect(subject.parameters_for_method).to eq("body, options = {}") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.parameters_for_method).to eq("id, options = {}") }
      end

      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it { expect(subject.parameters_for_method).to eq("petId, options = {}") }
      end
    end

    describe "#typed_parameters" do
      describe 'path /oauth/token' do
        it { expect(subject.typed_parameters).to eq("({ grant_type: String, client_id: String, client_secret: String, scope: String } body, ?Hash[untyped, untyped] options)") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.typed_parameters).to eq("(String id, ?Hash[untyped, untyped] options)") }
      end

      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it { expect(subject.typed_parameters).to eq("(String petId, ?Hash[untyped, untyped] options)") }
      end

      describe 'path /user/{username}' do
        let(:path_method) { ["/user/{username}", "put"] }
        it { expect(subject.typed_parameters).to eq("(String username, { id: Integer, username: String, firstName: String, lastName: String, email: String, password: String, phone: String, userStatus: Integer } body, ?Hash[untyped, untyped] options)") }
      end
    end

    describe 'to_yaml' do
      describe 'path /pet/{petId}' do
        let(:path_method) { ["/pet/{petId}", "delete"] }
        it "" do
          result = subject.to_yaml
          expect(result[:method_name]).to eq("deletePet")
          expect(result[:parameters]).to eq(["petId"])
          expect(result[:body]).to eq({})
        end
      end

      describe 'path /pet' do
        let(:path_method) { ["/pet", "put"] }
        it "to_yaml" do
          result = subject.to_yaml
          expect(result[:method_name]).to eq("updatePet")
          expect(result[:parameters]).to eq([])
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
        it { expect(subject.body_typed).to eq("({grant_type: String, client_id: String, client_secret: String, scope: String} body, ?Hash[untyped, untyped] options)") }
      end

      describe 'path /accounts/{id}' do
        let(:path_method) { ["/accounts/{id}", "get"] }
        it { expect(subject.body_typed).to eq(nil) }
      end

      describe 'path /accounts/{id}/contacts array of object' do
        let(:path_method) { ["/accounts/{id}/contacts", "post"] }
        it do
          expect(subject.body_typed)
            .to eq("({account_id: String, relationship: String, first_name: String, last_name: String, email: String, communications_opt_out: String, contact_numbers: Array[{type: String, number: String}]} body, ?Hash[untyped, untyped] options)")
        end
      end

      describe 'path /data/v1/policy object of object' do
        let(:path_method) { ["/data/v1/policy", "post"] }
        it do
          expect(subject.body_typed)
          .to eq("({payloads: Array[{identifier: {externalIdField: String, value: String}, data: {Account: {UUID: String}, InsuranceType: String}}]} body, ?Hash[untyped, untyped] options)")
        end
      end

      describe 'path /certificates array of string' do
        let(:path_method) { ["/certificates", "post"] }
        it do
          expect(subject.body_typed)
            .to eq("({type: String, policy_ids: Array[String], fields: {holder_name: String}} body, ?Hash[untyped, untyped] options)")
        end
      end
    end
  end
end
