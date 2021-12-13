import ballerina/jwt;
import ballerina/log;
import ballerina/http;

const SCOPE_CREATE = "product:create";
const SCOPE_UPDATE = "product:update";
const SCOPE_VIEW = "product:view";
const SCOPE_DELETE = "product:delete";

type Scope SCOPE_CREATE|SCOPE_DELETE|SCOPE_VIEW|SCOPE_UPDATE;

type Role record {|
    string name;
    Scope[] scopes = [];
|};

type User record {|
    int id;
    string firstName;
    string lastName;
    string username;
    string password;
    Role[] roles = [];
|};

User[] users = [];

function init() {
    Role admin = {name: "Admin", scopes: [SCOPE_CREATE, SCOPE_DELETE, SCOPE_UPDATE, SCOPE_VIEW]};
    Role manager = {name: "Admin", scopes: [SCOPE_CREATE, SCOPE_UPDATE, SCOPE_VIEW]};
    Role cashier = {name: "Admin", scopes: [SCOPE_VIEW]};

    users.push({id: 1, firstName: "Imesha", lastName: "Sudasingha", username: "imesha", password: "1234", roles: [admin]});
    users.push({id: 2, firstName: "John", lastName: "Doe", username: "john", password: "1234", roles: [manager]});
    users.push({id: 3, firstName: "Jane", lastName: "Doe", username: "jane", password: "1234", roles: [cashier]});
}

type LoginRequest record {|
    string username;
    string password;
|};

type LoginResponse record {|
    string token;
|};

listener httpListener = check new http:Listener(8080);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on httpListener {

    resource function post login(@http:Payload LoginRequest loginRequest) returns LoginResponse|error {
        User[] matched = users.filter(u => u.username == loginRequest.username && u.password == loginRequest.password);
        if matched.length() == 0 {
            return error("Unauthorized");
        }

        User user = matched[0];

        Scope[] scopeSet = user.roles.map(role => role.scopes)
            .reduce(function(Scope[] accum, Scope[] scopes) returns Scope[] {
                scopes.forEach(function(Scope scope) {
                    if accum.indexOf(scope) == () {
                        accum.push(scope);
                    }
                });
                return accum;
            }, []);

        string aggScopes = string:'join(" ", ...scopeSet);

        log:printInfo("Authenticating user with scopes", user = user, scopes = aggScopes);

        jwt:IssuerConfig issuerConfig = {
            username: user.username,
            issuer: "wso2",
            audience: "example.com",
            expTime: 3600,
            signatureConfig: {
                config: {
                    keyFile: "./resources/private.key"
                }
            },
            customClaims: {
                "scope": aggScopes
            }
        };

        string jwt = check jwt:issue(issuerConfig);
        return {token: jwt};
    }
}

type Product record {|
    int id?;
    string name;
    string description;
|};

Product[] products = [];
int id = 0;

http:JwtValidatorConfig jwtValidatorConfig = {
    issuer: "wso2",
    audience: "example.com",
    signatureConfig: {
        certFile: "./resources/public.cert"
    }
};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /products on httpListener {

    function init() {
        products.push({id: 1, name: "P 1", description: "Description 1"});
        products.push({id: 2, name: "P 2", description: "Description 2"});
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: jwtValidatorConfig
            }
        ]
    }
    resource function get .() returns Product[] {
        return products;
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: jwtValidatorConfig,
                scopes: [SCOPE_CREATE]
            }
        ]
    }
    resource function post .(@http:Payload Product product) returns error? {
        id += 1;
        product.id = id;
        products.push(product);
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: jwtValidatorConfig,
                scopes: [SCOPE_DELETE]
            }
        ]
    }
    resource function delete [int id]() returns error? {
        products = from var product in products
            where product?.id != id
            select product;
    }
}
