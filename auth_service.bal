import ballerina/http;
import ballerina/log;
import ballerina/jwt;
import fullstack_ballerina.types;

types:User[] users = [];

function init() {
    types:Role admin = {name: "Admin", scopes: [types:SCOPE_CREATE, types:SCOPE_DELETE, types:SCOPE_UPDATE, types:SCOPE_VIEW]};
    types:Role manager = {name: "Admin", scopes: [types:SCOPE_CREATE, types:SCOPE_UPDATE, types:SCOPE_VIEW]};
    types:Role cashier = {name: "Admin", scopes: [types:SCOPE_VIEW]};

    users.push({id: 1, firstName: "Imesha", lastName: "Sudasingha", username: "imesha", password: "1234", roles: [admin]});
    users.push({id: 2, firstName: "John", lastName: "Doe", username: "john", password: "1234", roles: [manager]});
    users.push({id: 3, firstName: "Jane", lastName: "Doe", username: "jane", password: "1234", roles: [cashier]});
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service / on httpListener {

    resource function post login(@http:Payload types:LoginRequest loginRequest) returns types:LoginResponse|error {
        types:User[] matched = users.filter(u => u.username == loginRequest.username && u.password == loginRequest.password);
        if matched.length() == 0 {
            return error("Unauthorized");
        }

        types:User user = matched[0];

        types:Scope[] scopeSet = user.roles.map(role => role.scopes)
            .reduce(function(types:Scope[] accum, types:Scope[] scopes) returns types:Scope[] {
            scopes.forEach(function(types:Scope scope) {
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
