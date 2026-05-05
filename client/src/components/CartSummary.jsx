// Displays the cart contents and calculates the total price of all items
function CartSummary({ items }) {
  const total = items.reduce((sum, item) => sum + item.price, 0);
  return (
    <div data-testid="cart-summary">
      <h2>Cart</h2>
      {items.length === 0 ? (
        <p>Your cart is empty</p>
      ) : (
        <>
          <ul>
            {items.map((item) => (
              <li key={item.id}>
                {item.name} — ${item.price.toFixed(2)}
              </li>
            ))}
          </ul>
          <p data-testid="cart-total">Total: ${total.toFixed(2)}</p>
        </>
      )}
    </div>
  );
}

export default CartSummary;
