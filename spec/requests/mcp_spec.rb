# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MCP endpoint' do
  let(:headers) do
    {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json',
      'HTTP_MCP_PROTOCOL_VERSION' => '2025-06-18'
    }
  end

  def rpc(payload)
    post '/mcp', params: payload.to_json, headers: headers
    JSON.parse(response.body)
  end

  it 'responds to initialize with the server info' do
    body = rpc(
      jsonrpc: '2.0', id: 1, method: 'initialize',
      params: {
        protocolVersion: '2025-06-18', capabilities: {},
        clientInfo: { name: 'rspec', version: '1.0' }
      }
    )

    expect(response).to have_http_status(:ok)
    expect(body.dig('result', 'serverInfo', 'name')).to eq('sepomex')
  end

  it 'lists the available tools' do
    body = rpc(jsonrpc: '2.0', id: 2, method: 'tools/list', params: {})

    names = body.dig('result', 'tools').map { |tool| tool['name'] }
    expect(names).to contain_exactly(
      'lookup_zip_code', 'search_zip_codes', 'list_states',
      'state_municipalities', 'search_cities'
    )
  end

  it 'calls a tool and returns structured content' do
    FactoryBot.create(:zip_code, d_codigo: '64000', d_asenta: 'Centro')

    body = rpc(
      jsonrpc: '2.0', id: 3, method: 'tools/call',
      params: { name: 'lookup_zip_code', arguments: { zip_code: '64000' } }
    )

    result = body['result']
    expect(result['isError']).to be(false)
    expect(result['structuredContent'].length).to eq(1)
    expect(result['content'].first['text']).to include('64000')
  end

  it 'returns a JSON-RPC error for an unknown tool' do
    body = rpc(
      jsonrpc: '2.0', id: 4, method: 'tools/call',
      params: { name: 'does_not_exist', arguments: {} }
    )

    expect(body['error']['code']).to eq(-32_602)
  end
end
