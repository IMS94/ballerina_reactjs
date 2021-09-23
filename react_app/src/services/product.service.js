import { Product, User } from "../entity";
import { secureClient } from "./client";

class ProductServiceImpl {

    getProducts(): Promise<Product[]> {
        return new Promise((resolve, reject) => {
            secureClient.get("products")
            .then(response => {
                resolve(response.data.map(d => new Product(d)));
            })
            .catch(err => reject(err));
        });
    }

    addProduct(product: Product): Promise {
        return new Promise((resolve, reject) => {
            secureClient.post("products", product)
            .then(response => {
                resolve();
            })
            .catch(err => reject(err));
        });
    }
}

const ProductService = new ProductServiceImpl();
export default ProductService;
