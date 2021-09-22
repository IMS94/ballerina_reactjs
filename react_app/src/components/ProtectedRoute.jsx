import { Redirect, Route } from "react-router-dom";
import authService from "../services/auth.service";

function ProtectedRoute({path, ...rest}) {

    if (authService.checkLoggedIn()) {
        return (
            <Route path={path} {...rest} />
        );
    }

    return (
        <Redirect form={path} to={"/login"} />
    );
}

export default ProtectedRoute;