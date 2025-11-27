# Shopping Cart Repository

**Shopping Cart** is a Salesforce Lightning Web Components (LWC)-based e-commerce application for managing products, orders, and shopping cart functionality. Built on the Salesforce platform, it provides a complete shopping experience with product catalog, cart management, and order processing capabilities.

## Overview

This Salesforce project provides:

- Modern shopping cart interface with Lightning Web Components
- Product catalog with filtering and search capabilities
- Real-time cart management with add/remove functionality
- Order processing and line item management
- Category-based product filtering
- Configurable components for Lightning App Builder and Experience Cloud
- Unpaid order detection and restoration

## Technology Stack

- **Platform**: Salesforce (API Version 65.0)
- **Frontend**: Lightning Web Components (LWC)
- **Backend**: Apex Classes with sharing rules
- **Messaging**: Lightning Message Service for component communication
- **Database**: Salesforce Custom Objects (Product__c, Order__c, Order_Line_Item__c)
- **Testing**: Jest framework for LWC unit tests
- **Development Tools**: Salesforce CLI, VS Code with Salesforce Extensions

## Architecture

### Core Components

#### Lightning Web Components (LWC)

- **`productMaster`**: Main shopping container component with configurable properties (card title, filter button visibility, cart icon visibility, default category). Serves as the parent container and orchestrates child components. Subscribes to cart messages and manages cart badge count. Configurable for both Lightning App Builder and Experience Cloud.

- **`productSearch`**: Handles product search and filtering logic. Queries products via `ProductService.getProducts()` with dynamic filter criteria. Subscribes to filter messages via Lightning Message Service. Supports default category filtering from parent component.

- **`productSearchForm`**: Search input form component that publishes search terms. Provides user interface for product name search.

- **`productsList`**: Displays search results in a grid layout. Maps through product data and renders individual product tiles.

- **`productTile`**: Individual product card displaying product image, name, price, total, quantity selector, and add/remove cart buttons. Publishes add/remove cart messages. Handles quantity changes and price calculations. Loads product images from ContentVersion using base64 encoding.

- **`productFilters`**: Modal dialog for advanced filtering (price range, category, size). Publishes filter criteria via Lightning Message Service.

- **`cartData`**: Shopping cart modal displaying cart items, quantities, totals, and checkout button. Receives cart data from parent component. Handles cart item removal and order creation.

- **`cartBadge`**: Cart badge component with unpaid order detection. Checks for existing "Due" status orders on load. Restores unpaid order items to cart automatically. Publishes unpaid order detection events.

- **`productMasterApparel`**: Variant of productMaster pre-configured for apparel category.

- **`productMasterPrograming`**: Variant of productMaster pre-configured for programming category.

#### Apex Classes

- **`ProductService`**: Main service class for product and order operations
  - `getProducts(String name, FilterWrapper filtersData)`: Queries products with dynamic filtering (name, price range, category, size)
  - `getProductImage(String contentVersionId)`: Retrieves base64-encoded product images from ContentVersion
  - `createOrder(Object data)`: Creates orders and order line items from cart data
  - `getOrderDetails(String orderId)`: Fetches order with related line items
  - `convertOrderLineItemsToCartItems(String orderId)`: Converts order line items to cart item format
  - Contains `FilterWrapper`, `ProductOrderWrapper`, and `OrderDetailsWrapper` inner classes

- **`OrderService`**: Service class for order management operations
  - `getOrders()`: Retrieves all orders for current user
  - `getOrderWithLineItems(String orderId)`: Gets specific order with line items
  - `getDueOrder()`: Finds most recent unpaid order (Status = 'Due') for current user

#### Aura Components

- **`orderDetailsRoute`**: Aura component for order details routing

### Message Channels

- **`productAddRemoveCartChannel`**: Broadcasts cart add/remove actions with product data
- **`productFilterChannel`**: Broadcasts filter criteria changes

## Key Features

### 1. Product Catalog Management

- Dynamic product search with real-time filtering
- Category, size, brand, and price range filters
- Product images stored as ContentVersions with base64 encoding for Experience Cloud compatibility
- Supports custom product fields: Name, Price, Brand, Category, Size, Image URL, Product Code

### 2. Shopping Cart Functionality

- Add/remove products with quantity selection
- Real-time cart total calculations
- Cart badge with item count
- Lightning Message Service for cross-component cart updates
- Persistent cart state across component interactions

### 3. Order Processing

- Create orders from cart items
- Order line items with product associations
- Order total price roll-up calculation
- Order status tracking ("Due" for unpaid orders)
- Automatic unpaid order restoration

### 4. Experience Builder Support

- Configurable component properties exposed in builder UI
- **Card Title**: Customize shopping card heading
- **Show Filter Button**: Toggle filter button visibility
- **Show Cart Icon**: Toggle cart icon display
- **Default Category**: Pre-filter products by category
- Supports both Lightning App Builder and Experience Cloud

### 5. Responsive Design

- SLDS (Salesforce Lightning Design System) styling
- Mobile-responsive layouts
- Lightning layouts for grid-based product display
- Modal dialogs for cart and filters

## Data Model

### Custom Objects

- **Product__c**: Product catalog with fields for Name, Price, Brand, Category, Size, Image URL, Product Code. Supports product images via ContentDocumentLink associations.

- **Order__c**: Shopping orders with Total Price roll-up and Status field. Tracks order creation date and associated line items.

- **Order_Line_Item__c**: Individual line items within orders. Links to Product__c and Order__c. Stores Price, Quantity, and Total Price for each product in the order.

### Relationships

- Product__c → ContentDocumentLink → ContentVersion (product images)
- Order__c → Order_Line_Item__c (one-to-many)
- Order_Line_Item__c → Product__c (lookup)
- Order__c has roll-up Total_Price__c from line items

### Record Types

No custom record types currently implemented. Standard object configurations used.

## Security & Access Control

- **Apex Security**: All Apex classes use `with sharing` to enforce user-level security
- **Field-Level Security**: Enforced through Salesforce standard mechanisms
- **Object Permissions**: Standard Salesforce object-level security applies
- **User Context**: Orders filtered by CreatedById for user isolation

## Recent Development

### Current Branch: `NCYD-Shopping-Cart`

Major features and enhancements implemented:

**Features:**
1. Upgraded all components to API version 65.0
2. Added Experience Builder configurable properties to productMaster
3. Implemented OrderService class for order management operations
4. Enhanced ProductService with order detail methods and wrapper classes
5. Added cartBadge component with unpaid order detection
6. Implemented default category filter property
7. Updated product tile layout (price and total on separate rows)
8. Added productMasterApparel and productMasterPrograming variants

**Status**: Active development - ready for testing and deployment

### Architecture Decisions

- **Lightning Message Service**: Chosen for component communication to avoid tight coupling and enable flexible component composition
- **Base64 Image Encoding**: Implemented to support Experience Cloud where URL-based ContentVersion access is restricted
- **Wrapper Classes**: Used for clean data transfer between Apex and LWC with proper @AuraEnabled annotations

## Project Structure

```
Shoppingcart/
├── force-app/                          # Salesforce DX source
│   └── main/
│       └── default/
│           ├── aura/                   # Aura components
│           │   └── orderDetailsRoute/  # Order routing component
│           ├── classes/                # Apex classes
│           │   ├── OrderService.cls    # Order management service
│           │   ├── OrderService.cls-meta.xml
│           │   ├── ProductService.cls  # Product and order operations
│           │   └── ProductService.cls-meta.xml
│           ├── flexipages/             # Lightning pages
│           │   ├── Order_Record_Page.flexipage-meta.xml
│           │   └── Product_Record_Page.flexipage-meta.xml
│           ├── homePageLayouts/        # Home page layouts
│           │   └── DE Default.homePageLayout-meta.xml
│           ├── lwc/                    # Lightning Web Components (11 components)
│           │   ├── cartBadge/          # Cart badge with unpaid order detection
│           │   ├── cartData/           # Cart modal and data management
│           │   ├── productFilters/     # Filter modal component
│           │   ├── productMaster/      # Main shopping container
│           │   ├── productMasterApparel/    # Apparel category variant
│           │   ├── productMasterPrograming/ # Programming category variant
│           │   ├── productSearch/      # Search and filter logic
│           │   ├── productSearchForm/  # Search input form
│           │   ├── productsList/       # Product grid display
│           │   ├── productTile/        # Individual product card
│           │   └── jsconfig.json
│           ├── messageChannels/        # Lightning Message Service channels
│           │   ├── productAddRemoveCartChannel.messageChannel-meta.xml
│           │   └── productFilterChannel.messageChannel-meta.xml
│           ├── objects/                # Custom objects
│           │   ├── Order__c/           # Order object with Total Price field
│           │   ├── Order_Line_Item__c/ # Line items with Product/Order lookups
│           │   └── Product__c/         # Product catalog (6 custom fields)
│           └── tabs/                   # Custom tabs
│               ├── Order__c.tab-meta.xml
│               ├── Order_Line_Item__c.tab-meta.xml
│               └── Product__c.tab-meta.xml
├── config/
│   └── project-scratch-def.json       # Scratch org definition
├── docs/                               # Documentation
│   └── how-to-create-repository-summary.md
├── manifest/
│   └── package.xml                     # Package deployment manifest
├── jest.config.js                      # Jest test configuration
├── package.json                        # Node.js dependencies
├── sfdx-project.json                   # Salesforce DX project config
├── README.md                           # Project readme
└── REPOSITORY_SUMMARY.md               # This file
```

## Development Workflow

### Prerequisites

- Salesforce CLI (sf) version 2.x or higher
- Node.js and npm
- VS Code with Salesforce Extensions
- Git
- Access to Salesforce org (DevHub for scratch orgs or sandbox)

### Available Scripts

```bash
sf org list                             # List authenticated orgs
sf project deploy start --manifest manifest/package.xml # Deploy all metadata
sf project retrieve start --manifest manifest/package.xml # Retrieve metadata
sf project deploy start --source-dir force-app/main/default/lwc # Deploy LWC components
```

### Common Tasks

```bash
# Authenticate to org
sf org login web --alias MyOrg

# Deploy all changes
sf project deploy start --manifest manifest/package.xml --target-org MyOrg

# Deploy specific component
sf project deploy start --source-dir force-app/main/default/lwc/productMaster --target-org MyOrg

# Retrieve metadata from org
sf project retrieve start --manifest manifest/package.xml --target-org MyOrg

# Run tests
npm test

# Open org
sf org open --target-org MyOrg
```

## Testing

### Framework
- **Jest** for LWC unit tests (configured via jest.config.js)
- **Apex Test Classes** (to be implemented)

### Test Locations
- LWC tests: `force-app/main/default/lwc/[componentName]/__tests__/`

### Running Tests
```bash
npm test                    # Run all Jest tests
npm test -- --coverage     # Run with coverage report
```

### Testing Patterns
- Mock wire adapters for Apex method calls
- Test component rendering and user interactions
- Verify Lightning Message Service publications
- Test error handling and edge cases

## Integration Points

### Salesforce Content Management
- **Service**: ContentVersion and ContentDocumentLink
- **Purpose**: Store and retrieve product images
- **Authentication**: Salesforce session-based
- **Implementation**: Base64 encoding via `ProductService.getProductImage()`

### Lightning Message Service
- **Channels**: productAddRemoveCartChannel, productFilterChannel
- **Purpose**: Inter-component communication
- **Pattern**: Publish-subscribe for loosely coupled architecture

## Important Notes for LLMs/AI Assistants

When working with this codebase:

1. **API Version Consistency**: All components use API version 65.0. When creating new components or classes, maintain this version consistency.

2. **Lightning Message Service Pattern**: Components use LMS for communication instead of custom events. Always use the established message channels (`productAddRemoveCartChannel__c`, `productFilterChannel__c`) for cart and filter operations.

3. **Image Handling**: Product images are stored as ContentVersions and converted to base64 data URIs. This is required for Experience Cloud compatibility. Never reference ContentVersion URLs directly.

4. **Component Properties**: When adding configurable properties to LWC components, define them for both `lightning__AppPage,lightning__HomePage` and `lightningCommunity__Default` targets to ensure consistency across builders.

5. **Apex Sharing Rules**: All Apex classes use `with sharing` to enforce user-level security. Maintain this pattern for new classes.

6. **Data Model Dependencies**: Order__c has a calculated Total_Price__c field. When working with orders, ensure Order_Line_Item__c records exist before querying totals.

7. **Component Hierarchy**: productMaster is the parent container. productSearch, productFilters, and cartData are child components. Maintain this hierarchy when extending functionality.

8. **Boolean @api Properties**: Never initialize boolean @api properties to `true` in JavaScript. Set defaults in the metadata file only to avoid LWC validation errors.

9. **Cart State Management**: Cart data is managed through Lightning Message Service messages. Always publish cart changes through `productAddRemoveCartChannel__c` to keep all components synchronized.

10. **Filter Implementation**: Filters use the `FilterWrapper` Apex class with optional properties (minPrice, maxPrice, category, size). Default category filtering is applied in productSearch's connectedCallback.

11. **Order Status Field**: Orders have a Status__c field. Use "Due" for unpaid orders to enable cart restoration via cartBadge component.

12. **ContentVersion Access**: In Experience Cloud, use `ProductService.getProductImage()` method rather than direct ContentVersion queries to handle security contexts properly.

## Documentation Files

- **REPOSITORY_SUMMARY.md**: This file - comprehensive project overview
- **README.md**: Quick start guide and Salesforce DX resources
- **docs/how-to-create-repository-summary.md**: Instructions for maintaining REPOSITORY_SUMMARY.md
- **.cursor/rules/**: Cursor AI rules for Apex and LWC best practices
  - `apex-best-practices.mdc`: Apex coding guidelines
  - `lwc-best-practices.mdc`: LWC coding standards
  - `lwc-jest-tests.mdc`: Jest testing guidelines
  - Additional field creation rules

---

**Last Updated**: November 27, 2025 - Based on branch `NCYD-Shopping-Cart`  
**Repository**: Shoppingcart - National Center for Youth Development  
**Platform**: Salesforce (API Version 65.0)  
**Active Environments**: NCYDSandbox (Partial Sandbox), NCYD Prod

