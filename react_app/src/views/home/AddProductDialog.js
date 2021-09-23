import { Box, Button, Dialog, DialogActions, DialogContent, DialogTitle, Grid, TextField } from "@material-ui/core";
import React from "react";
import { useFormik } from "formik";
import ProductService from "../../services/product.service";
import { Product } from "../../entity";
import { useSnackbar } from "notistack";

function AddProductDialog({ open, onClose }) {
    const { enqueueSnackbar } = useSnackbar();
    const { values, handleChange, handleSubmit } = useFormik({
        initialValues: {
            productName: "",
            productDescription: ""
        },
        onSubmit: handleFormSubmit
    });

    function handleFormSubmit(values) {
        ProductService.addProduct(new Product({ name: values.productName, description: values.productDescription }))
            .then(() => {
                enqueueSnackbar("Product added!", { variant: "success" });
                onClose();
            })
            .catch(err => enqueueSnackbar("Failed to add product", { variant: "error" }));
    }

    return (
        <Dialog open={open} onClose={onClose} maxWidth={"sm"}>
            <DialogTitle>Add Product</DialogTitle>
            <DialogContent dividers>
                <Box p={0}>
                    <Grid container spacing={2}>
                        <Grid item xs={12}>
                            <TextField
                                variant="outlined"
                                placeholder={"Product Name"}
                                name={"productName"}
                                value={values.productName}
                                onChange={handleChange}
                                fullWidth
                            />
                        </Grid>

                        <Grid item xs={12}>
                            <TextField
                                variant="outlined"
                                name={"productDescription"}
                                placeholder={"Product Description"}
                                value={values.productDescription}
                                onChange={handleChange}
                                minRows={2}
                                multiline
                                fullWidth
                            />
                        </Grid>
                    </Grid>
                </Box>
            </DialogContent>
            <DialogActions>
                <Button onClick={onClose}>Cancel</Button>
                <Button
                    variant={"contained"}
                    color={"primary"}
                    onClick={handleSubmit}
                >
                    Add
                </Button>
            </DialogActions>
        </Dialog>
    );
}

export default AddProductDialog;