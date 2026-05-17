import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import ProductCard from '../components/ProductCard';
import CartSummary from '../components/CartSummary';

const mockProduct = { id: 1, name: 'Widget', price: 9.99, stock: 5 };

describe('ProductCard', () => {
  it('renders product name and price', () => {
    render(<ProductCard product={mockProduct} onAddToCart={() => {}} />);
    expect(screen.getByText('Widget')).toBeInTheDocument();
    expect(screen.getByText('$9.99')).toBeInTheDocument();
  });

  it('calls onAddToCart when button clicked', () => {
    const handler = vi.fn();
    render(<ProductCard product={mockProduct} onAddToCart={handler} />);
    fireEvent.click(screen.getByRole('button', { name: /add to cart/i }));
    expect(handler).toHaveBeenCalledWith(mockProduct);
  });
});

describe('CartSummary', () => {
  it('shows empty message when cart is empty', () => {
    render(<CartSummary items={[]} />);
    expect(screen.getByText(/your cart is empty/i)).toBeInTheDocument();
  });

  it('renders items and correct total', () => {
    const items = [
      { id: 1, name: 'Widget', price: 9.99 },
      { id: 2, name: 'Gadget', price: 4.99 },
    ];
    render(<CartSummary items={items} />);
    expect(screen.getByText(/Widget/)).toBeInTheDocument();
    expect(screen.getByTestId('cart-total').textContent).toBe('Total: $14.98');
  });
});
