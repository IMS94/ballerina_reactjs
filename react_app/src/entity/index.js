
export class LoginResponse {
    token;

    constructor(obj) {
        this.token = obj.token;
    }
}

export class User {
    username;

    constructor(obj) {
        this.username = obj.username;
    }
}

export class Product {
    id;
    name;
    description;

    constructor(obj: Product) {
        this.id = obj.id;
        this.name = obj.name;
        this.description = obj.description;
    }
}
