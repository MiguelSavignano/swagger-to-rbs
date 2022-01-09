require 'json'
require 'pry'
require_relative '../lib/swagger2_rbs'
require_relative '../lib/swagger2_rbs/rbs_type'


describe "RbsType" do
  let(:subject) {  }
  it 'nil values' do
    data = { "400" => nil, "200" => { "success" => "string" } }
    result = Swagger2Rbs::RbsType.new(data, symbolize_keys: false).write_types
    expect(result).to eq('{ "400" => untyped, "200" => {"success" => String} }')
  end

  it 'array' do
    data = { "errors" => [{ "success" => "string" }] }
    result = Swagger2Rbs::RbsType.new(data).write_types
    expect(result).to eq('{ errors: Array[{success: String}] }')
  end
end
