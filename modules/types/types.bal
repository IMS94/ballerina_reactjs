public type LoginRequest record {|
    string username;
    string password;
|};

public type LoginResponse record {|
    string token;
|};

public type Product record {|
    int id?;
    string name;
    string description;
|};

public type Role record {|
    string name;
    Scope[] scopes = [];
|};

public type User record {|
    int id;
    string firstName;
    string lastName;
    string username;
    string password;
    Role[] roles = [];
|};

public const SCOPE_CREATE = "product:create";
public const SCOPE_UPDATE = "product:update";
public const SCOPE_VIEW = "product:view";
public const SCOPE_DELETE = "product:delete";

# Scopes allowed for users
public type Scope SCOPE_CREATE|SCOPE_DELETE|SCOPE_VIEW|SCOPE_UPDATE;

