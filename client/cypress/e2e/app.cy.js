describe('ShopSmart App', () => {
  beforeEach(() => {
    // Stub the health API so tests don't need a live backend
    cy.intercept('GET', '/api/health', {
      statusCode: 200,
      body: {
        status: 'ok',
        message: 'ShopSmart Backend is running',
        timestamp: new Date().toISOString(),
      },
    }).as('healthCheck');
  });

  it('loads the homepage and shows ShopSmart title', () => {
    cy.visit('/');
    cy.contains('h1', 'ShopSmart').should('be.visible');
  });

  it('displays backend status after health check', () => {
    cy.visit('/');
    cy.wait('@healthCheck');
    cy.contains('Status:').should('be.visible');
    cy.contains('ok').should('be.visible');
  });
});
