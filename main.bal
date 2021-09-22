import ballerina/jwt;
import ballerina/http;

const CREATOR = "creator";
const VIEWER = "viewer";
type Role CREATOR | VIEWER;

type User record {|
    int id;
    string firstName;
    string lastName;
    string username;
    string password;
    Role[] roles;
|};

User[] users = [];

function init() {
    users.push({id: 1, firstName: "Imesha", lastName: "Sudasingha", username: "imesha", password: "1234", roles: [VIEWER]});
}

type LoginRequest record {|
    string username;
    string password;
|};

type LoginResponse record {|
    string token;
|};

listener httpListener = new http:Listener(8080);

@http:ServiceConfig{
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
                "roles": user.roles
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
    },
    scopeKey: "roles"
};

@http:ServiceConfig{
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
                jwtValidatorConfig: jwtValidatorConfig,
                scopes: [VIEWER]
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
                scopes: [CREATOR]
            }
        ]
    }
    resource function post .(@http:Payload Product product) returns error? {
        id += 1;
        product.id = id;
        products.push(product);
    }
}
