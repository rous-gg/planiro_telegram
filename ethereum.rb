require 'ethereum.rb'
require 'eth'

module Ethereum
  class Client
    def send_command(command,args)
      if ["eth_getTransactionCount", "eth_getBalance", "eth_call"].include?(command)
        args << "latest"
      end

      payload = {jsonrpc: "2.0", method: command, params: encode_params(args), id: get_id}
      @logger.info("Sending #{payload.to_json}") if @log
      if @batch
        @batch << payload
        return true
      else
        output = JSON.parse(send_single(payload.to_json))
        @logger.info("Received #{output.to_json}") if @log
        reset_id
        raise IOError, output["error"]["message"] if output["error"]
        return output
      end
    end
  end
end

# PRIVATE_WALLET_KEY = '50cb75037145b5ad9a71bead7dc0e7222cf3421a318d8899d6087160b4ebe779'
PRIVATE_WALLET_KEY = '0x58a1be64e2d45e8bfaf664ae138856e3991a8b67'

ETH_CLIENT = Ethereum::HttpClient.new('http://localhost:8545')
# client = Ethereum::HttpClient.new('http://hackaton.izx.io:18555')

# contract = Ethereum::Contract.create(client: client, file: "organization.sol", address: "0x032682d98079a32a0cf723a30f88d7f7a70429ae")

ORG_CONTRACT = Ethereum::Contract.create(client: ETH_CLIENT, file: 'organization.sol')
# contract.key = Eth::Key.new(priv: PRIVATE_WALLET_KEY)
ORG_CONTRACT.deploy_and_wait
# puts contract.transact.new_project(1)
# puts address
# require 'byebug'
# debugger
# puts 'sss'
