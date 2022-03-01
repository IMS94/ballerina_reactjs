import ballerina/http;
import fullstack_ballerina.types;

http:JwtValidatorConfig jwtValidatorConfig = {
    issuer: "wso2",
    audience: "example.com",
    scopeKey: "permissions",
    signatureConfig: {
        certFile: "./resources/public.cert"
    }
};

types:Product[] products = [];
int id = 0;

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
    resource function get .() returns types:Product[] {
        return products;
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: jwtValidatorConfig,
                scopes: [types:SCOPE_CREATE]
            }
        ]
    }
    resource function post .(@http:Payload types:Product product) returns error? {
        lock {
            id += 1;
            product.id = id;
            products.push(product);
        }
    }

    @http:ResourceConfig {
        auth: [
            {
                jwtValidatorConfig: jwtValidatorConfig,
                scopes: [types:SCOPE_DELETE]
            }
        ]
    }
    resource function delete [int id]() returns error? {
        products = from var product in products
            where product?.id != id
            select product;
    }
}
