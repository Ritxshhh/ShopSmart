// Displays a single product with its name, price, stock, and an add-to-cart button
function ProductCard({ product, onAddToCart }) {
  return (
    <div data-testid="product-card">
      <h3>{product.name}</h3>
      <p>${product.price.toFixed(2)}</p>
      <p>In stock: {product.stock}</p>
      <button onClick={() => onAddToCart(product)}>Add to Cart</button>
    </div>
  );
}

export default ProductCard;
