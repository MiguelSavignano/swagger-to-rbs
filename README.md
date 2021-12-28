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
