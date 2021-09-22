import axios from "axios";
import AuthService from "./auth.service";

const client = axios.create({
    baseURL: "http://localhost:8080/"
});

const secureClient = axios.create({
    baseURL: "http://localhost:8080/",
});

secureClient.interceptors.request.use((config) => {
    let token = AuthService.getToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
});


export {
    client,
    secureClient
}
