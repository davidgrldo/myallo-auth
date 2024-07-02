local http = require "resty.http"
local jwt_decoder = require "resty.jwt"
local cjson = require "cjson"

local function validate_config(conf)
    if not conf.realm or not conf.keycloak_url then
        error("Missing required configuration options (realm or keycloak_url)")
    end
end

local function log_error(message)
    ngx.log(ngx.ERR, "MyAllo Auth - " .. message)
    ngx.status = 401
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode({
        message = message
    }))
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

local function log_notice(message)
    ngx.log(ngx.NOTICE, message)
end

local function validate_token(token, issuer_uri, with_bearer)
    local httpc = http.new()
    local res, err = httpc:request_uri(issuer_uri, {
        method = "GET",
        query = {
            token = token
        },
        headers = {
            ["Authorization"] = with_bearer and "Bearer " .. token or token
        }
    })

    if not res then
        log_error("Failed to validate token: " .. err)
    end

    if res.status ~= 200 then
        log_error("Invalid token: " .. res.status)
    end

    log_notice("Token validated successfully")
end

local function parse_token(token)
    local jwt = jwt_decoder:load_jwt(token)
    if not jwt.valid then
        log_error("Invalid token format")
    end

    return jwt
end

local MyAlloAuthHandler = {}

function MyAlloAuthHandler:access(conf)
    validate_config(conf)

    local access_token = ngx.req.get_headers()["Authorization"]

    if not access_token then
        log_error("Authorization header is missing")
    end

    local token
    if conf.with_bearer then
        _, _, token = string.find(access_token, "Bearer%s+(.+)")
    else
        token = access_token
    end

    if not token then
        log_error("Invalid token format")
    end

    local issuer_uri = conf.keycloak_url .. "realms/" .. conf.realm
    validate_token(token, issuer_uri, with_bearer)

    local jwt = parse_token(token)

    local claims = jwt.payload

    -- Check token expiration
    local exp = claims["exp"]
    local now = ngx.time()
    if exp < now then
        log_error("Token expired")
    end
end

return MyAlloAuthHandler
