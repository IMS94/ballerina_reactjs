import { CircularProgress, Container, makeStyles } from "@material-ui/core";
import { useEffect, useState } from "react";
import { Redirect, Route, Switch } from "react-router-dom";
import ProtectedRoute from "../components/ProtectedRoute";
import LoginView from "./login";
import HomeView from "./home";
import AuthService from "../services/auth.service";
import { useHistory } from "react-router";


const useStyles = makeStyles((theme) => ({
    root: {
        height: "100vh",
        backgroundColor: theme.palette.grey[500]
    }
}));


export default function SampleApp() {
    const classes = useStyles();
    const history = useHistory();

    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (AuthService.checkLoggedIn()) {
            history.push();
        }
    }, []);

    return (
        <Container maxWidth={false} className={classes.root} disableGutters>
            {loading && <CircularProgress />}

            {!loading && (
                <Switch>
                    <Route path="/login" component={LoginView} />
                    <ProtectedRoute path="/home" component={HomeView} />
                    <Redirect to="/login" />
                </Switch>
            )}
        </Container>
    );
}