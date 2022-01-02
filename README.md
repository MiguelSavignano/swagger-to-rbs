### Usage

Dowload swagger spec

Example:

```
curl https://petstore3.swagger.io/api/v3/openapi.json > swagger.json
```

Generate http client based on [Httparty gem](https://github.com/jnunemaker/httparty)

```
ruby lib/index.rb MyApi
```

Result:

```rb
require 'httparty'

class PetApi
  include HTTParty
  base_uri "/api/v3"
  #...

  def getPetById(petId, params, options = {})
    self.class.get("/pet/#{petId}", params: params.to_json, headers: { 'Content-Type' => 'application/json' }.merge(options))
  end

  def updatePet(body, options = {})
    self.class.put("/pet", body: body.to_json, headers: { 'Content-Type' => 'application/json' }.merge(options))
  end

  def addPet(body, options = {})
    self.class.post("/pet", body: body.to_json, headers: { 'Content-Type' => 'application/json' }.merge(options))
  end
  #...
end
```

### Send default header in all request

Authorization example:

```
api = MyApi.new

MyApi.headers(Authorization: "Bearer #{access_token}")
MyApi.base_uri("http://otherurl.test/api/v1)

api.getPetById(1)
```
