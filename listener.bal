import ballerina/http;

listener httpListener = check new http:Listener(8080);
