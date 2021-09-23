import { Button, AppBar, Card, CardContent, CircularProgress, Container, Grid, IconButton, makeStyles, Toolbar, Typography, Box, Divider, List, ListItem, ListItemText, CardActions } from "@material-ui/core";
import { Alert, AlertTitle } from "@material-ui/lab";
import { useSnackbar } from "notistack";
import { useEffect, useState } from "react";
import { Person, Menu as MenuIcon } from "@material-ui/icons";
import { useHistory } from "react-router-dom";
import AuthService from "../../services/auth.service";
import ProductService from "../../services/product.service";
import { Product } from "../../entity";
import AddProductDialog from "./AddProductDialog";

const useStyles = makeStyles((theme) => ({
    root: {
        height: "100%"
    },
    grid: {
        height: "100%"
    },
    logoutBtn: {
        marginLeft: "auto"
    },
    addButton: {
        marginLeft: "auto"
    }
}));


function HomeView() {
    const { enqueueSnackbar } = useSnackbar();
    const history = useHistory();
    const classes = useStyles();

    const [user, setUser] = useState();
    const [addProduct, setAddProduct] = useState(false);
    const [loading, setLoading] = useState(false);
    const [products, setProducts] = useState([]);

    useEffect(() => {
        loadProducts();
    }, []);

    function loadProducts() {
        setLoading(true);
        ProductService.getProducts()
            .then(products => setProducts(products))
            .catch(err => enqueueSnackbar("Unable to load products", { variant: "error" }))
            .finally(() => setLoading(false));
    }

    const handleLogout = () => {
        AuthService.logout();
        history.push("/");
    }

    const handleAddProductDialogClose = () => {
        setAddProduct(false);
        loadProducts();
    }
    const openAddProductDialog = () => setAddProduct(true);

    return (
        <Container maxWidth={false} className={classes.root} disableGutters>
            <AppBar position="static">
                <Toolbar>
                    <IconButton edge="start" className={classes.menuButton} color="inherit" aria-label="menu">
                        <MenuIcon />
                    </IconButton>
                    <Typography variant="h6" className={classes.title}>
                        Demo
                    </Typography>
                    <Button color="inherit" onClick={handleLogout} className={classes.logoutBtn}>Logout</Button>
                </Toolbar>
            </AppBar>
            <Grid container
                justifyContent={"center"}
                alignContent={"center"}
                className={classes.grid}
                spacing={3}
            >
                <Grid item xs={6}>
                    <Card>
                        <CardContent>
                            {loading && (
                                <CircularProgress />
                            )}

                            {products.length > 0 && (
                                <List>
                                    {products.map((p: Product) => (
                                        <>
                                            <ListItem>
                                                <ListItemText primary={p.name} secondary={p.description} />
                                            </ListItem>
                                            <Divider />
                                        </>
                                    ))}
                                </List>
                            )}

                            {addProduct && <AddProductDialog open={addProduct} onClose={handleAddProductDialogClose} />}
                        </CardContent>
                        <CardActions>
                            <Button
                                variant={"contained"}
                                color={"primary"}
                                className={classes.addButton}
                                onClick={openAddProductDialog}
                            >
                                Add
                            </Button>
                        </CardActions>
                    </Card>
                </Grid>
            </Grid>
        </Container>
    );
}

export default HomeView;