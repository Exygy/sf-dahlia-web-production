module SalesforceService
  # encapsulate all Salesforce Account/Person querying functions
  class AccountService < SalesforceService::Base
    def self.create(params)
      api_post('/Person', params)
    end

    def self.get(id)
      api_get("/Person/#{id}")
    end
  end
end