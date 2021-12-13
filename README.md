# React.js (frontend) + Ballerina (backend)

An example on writing the backend of a React.js app using Ballerina programming language.

## Solution Overview

### Backend (Ballerina)

Backend has an authentication service at `/login` and a product service (Rest API) at `/products`.
The product service is secured with jwt auth. The auth service (`/login`) will generate and return a JWT upon successful login.
Same JWT should be passed to the `/products` service in order to access.

## Frontend (React.js)
Frontend (React.js) app has a simple login page which invokes the auth service mentioned to obtain a JWT and once logged in
it shows functionalities to list, create, delete products.
