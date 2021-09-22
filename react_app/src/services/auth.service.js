import { LoginResponse, User } from "../entity";
import { client } from "./client";


class AuthServiceImpl {

    authenticated;

    checkLoggedIn() {
        let token = this.getToken();
        if (!token) {
            return false;
        }

        try {
            let payload = token.split(".")[1];
            payload = JSON.parse(atob(payload));
            return payload["exp"] && payload["exp"] > Date.now() / 1000;
        } catch (e) {
            return false;
        }
    }

    setToken(token) {
        localStorage.setItem("token", token);
    }

    getToken() {
        return localStorage.getItem("token");
    }

    logout() {
        this.setToken(null);
    }

    login(username, password) {
        let params = {
            username,
            password
        };

        return new Promise((resolve, reject) => {
            client.post('login', params).then(response => {
                resolve(new LoginResponse(response.data));
            }).catch(reason => {
                reject("Authentication failed");
            })
        });
    }
}

const AuthService = new AuthServiceImpl();
export default AuthService;