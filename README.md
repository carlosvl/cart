# Shopping Cart - Salesforce LWC Application

![Shopping Cart Demo](https://github.com/Rijwandeltax/cart/blob/master/Shopping%20Cart%20in%20LWC%20Salesforce.gif)

A modern e-commerce shopping cart application built with Salesforce Lightning Web Components (LWC), featuring product catalog, filtering, cart management, and order processing.

## 🚀 Quick Start

For a comprehensive overview of the project architecture, components, and development guidelines, **always read [`REPOSITORY_SUMMARY.md`](./REPOSITORY_SUMMARY.md) first**.

## 📋 Features

- **Product Catalog**: Browse products with images, pricing, and categories
- **Advanced Filtering**: Filter by category, size, brand, and price range
- **Shopping Cart**: Real-time cart management with add/remove functionality
- **Order Processing**: Create and manage orders with line items
- **Experience Cloud Ready**: Configurable components for Lightning and Experience Cloud
- **Unpaid Order Detection**: Automatically restore incomplete orders
- **Mobile Responsive**: SLDS-based responsive design

## 🛠️ Technology Stack

- **Salesforce Platform**: API Version 65.0
- **Lightning Web Components** (11 custom components)
- **Apex Classes**: ProductService, OrderService
- **Lightning Message Service**: Component communication
- **Custom Objects**: Product__c, Order__c, Order_Line_Item__c

## 📁 Key Components

| Component | Description |
|-----------|-------------|
| `productMaster` | Main shopping container with configurable properties |
| `productSearch` | Search and filter logic with default category support |
| `productTile` | Individual product card with cart actions |
| `cartData` | Shopping cart modal and checkout |
| `cartBadge` | Cart badge with unpaid order detection |
| `productFilters` | Advanced filter modal |

## 🚀 Development Setup

### Prerequisites
- Salesforce CLI (sf) v2.x+
- Node.js and npm
- VS Code with Salesforce Extensions
- Git

### Authentication
```bash
# Authenticate to your org
sf org login web --alias MyOrg
```

### Deploy to Org
```bash
# Deploy all metadata
sf project deploy start --manifest manifest/package.xml --target-org MyOrg

# Deploy specific component
sf project deploy start --source-dir force-app/main/default/lwc/productMaster --target-org MyOrg
```

### Retrieve from Org
```bash
# Retrieve all metadata
sf project retrieve start --manifest manifest/package.xml --target-org MyOrg
```

## 🧪 Testing

```bash
# Run Jest tests
npm test

# Run with coverage
npm test -- --coverage
```

## 📊 Data Model

```
Product__c
  ├── Fields: Name, Price, Brand, Category, Size, Image_URL, Product_Code
  └── Images via ContentVersion

Order__c
  ├── Field: Total_Price__c (rollup), Status__c
  └── Order_Line_Item__c (related)
        ├── Product__c (lookup)
        ├── Price__c, Quantity__c, Total_Price__c
        └── Order__c (lookup)
```

## 🎨 Configuration

### Experience Builder Properties

The `productMaster` component exposes these configurable properties:

- **Card Title**: Customize the shopping card heading
- **Show Filter Button**: Toggle filter button visibility
- **Show Cart Icon**: Toggle cart icon display  
- **Default Category**: Pre-filter products by category (e.g., "Apparel", "Programming")

## 📚 Documentation

- **[REPOSITORY_SUMMARY.md](./REPOSITORY_SUMMARY.md)** - Complete project architecture and guidelines
- **[docs/how-to-create-repository-summary.md](./docs/how-to-create-repository-summary.md)** - Documentation maintenance guide
- **Cursor Rules**: `.cursor/rules/` - AI coding guidelines for Apex and LWC

## 🔗 Salesforce Resources

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Lightning Web Components Dev Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)

## 📝 Recent Updates

- ✅ Upgraded to API version 65.0
- ✅ Added Experience Builder configurable properties
- ✅ Implemented OrderService for order management
- ✅ Added unpaid order detection and restoration
- ✅ Implemented default category filtering
- ✅ Enhanced product tile layout

## 📄 License

This project is part of the National Center for Youth Development Salesforce implementation.

---

![Demo Screenshot](https://techdicer.com/wp-content/uploads/2022/08/Shopping-cart-in-lwc1-1024x457.png)

**For detailed architecture, component documentation, and development guidelines, see [REPOSITORY_SUMMARY.md](./REPOSITORY_SUMMARY.md)**
