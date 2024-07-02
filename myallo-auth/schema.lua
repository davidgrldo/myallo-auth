local typedefs = require "kong.db.schema.typedefs"

return {
    name = "myallo-auth",
    fields = {{
        consumer = typedefs.no_consumer
    }, {
        protocols = typedefs.protocols_http
    }, {
        config = {
            type = "record",
            fields = {{
                keycloak_url = {
                    type = "string",
                    required = true,
                    match = "https?://.+"
                }
            }, {
                realm = {
                    type = "string",
                    required = true,
                    default = "realm-name"
                }
            }, {
                client_id = {
                    type = "string",
                    required = true
                }
            }, {
                with_bearer = {
                    type = "boolean",
                    default = true
                }
            }}
        }
    }}
}
