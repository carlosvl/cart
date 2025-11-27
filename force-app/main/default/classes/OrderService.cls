public with sharing class OrderService {
    /**
     * Method to retrieve a list of orders for the current user
     * @return List<Order__c> List of orders
     */
    @AuraEnabled(cacheable=true)
    public static List<Order__c> getOrders() {
        // Get the current user's ID
        Id userId = UserInfo.getUserId();
        
        try {
            // Query orders created by the current user
            // In a real-world scenario, you might want to add more filtering options
            List<Order__c> orders = [
                SELECT Id, Name, CreatedDate, Total_Price__c, Status__c
                FROM Order__c
                WHERE CreatedById = :userId
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
            
            return orders;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving orders: ' + e.getMessage());
        }
    }
    
    /**
     * Method to get a specific order with its line items
     * @param orderId The ID of the order to retrieve
     * @return ProductService.OrderDetailsWrapper Wrapper containing order and line items
     */
    @AuraEnabled(cacheable=true)
    public static ProductService.OrderDetailsWrapper getOrderWithLineItems(String orderId) {
        try {
            // Check if orderId is valid
            if (String.isBlank(orderId)) {
                // Return empty wrapper instead of null to avoid null reference errors
                ProductService.OrderDetailsWrapper emptyWrapper = new ProductService.OrderDetailsWrapper();
                emptyWrapper.order = new Order__c(); // Empty order object
                emptyWrapper.lineItems = new List<Order_Line_Item__c>(); // Empty line items list
                return emptyWrapper;
            }
            
            // Delegate to the existing method in ProductService
            return ProductService.getOrderDetails(orderId);
        } catch (Exception e) {
            // Log the error and return an empty wrapper
            System.debug('Error in getOrderWithLineItems: ' + e.getMessage());
            
            ProductService.OrderDetailsWrapper emptyWrapper = new ProductService.OrderDetailsWrapper();
            emptyWrapper.order = new Order__c();
            emptyWrapper.lineItems = new List<Order_Line_Item__c>();
            return emptyWrapper;
        }
    }
    
    /**
     * Method to get the latest order with "Due" status for the current user
     * @return ProductService.OrderDetailsWrapper Wrapper containing order and line items
     */
    @AuraEnabled
    public static ProductService.OrderDetailsWrapper getDueOrder() {
        // Get the current user's ID
        Id userId = UserInfo.getUserId();
        
        try {
            // Query for the most recent order with "Due" status
            List<Order__c> dueOrders = [
                SELECT Id, Name, CreatedDate, Total_Price__c, Status__c
                FROM Order__c
                WHERE CreatedById = :userId
                AND Status__c = 'Due'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            if (!dueOrders.isEmpty()) {
                // Get the order details with line items
                return ProductService.getOrderDetails(dueOrders[0].Id);
            } else {
                // Return empty wrapper if no due orders found
                ProductService.OrderDetailsWrapper emptyWrapper = new ProductService.OrderDetailsWrapper();
                emptyWrapper.order = new Order__c();
                emptyWrapper.lineItems = new List<Order_Line_Item__c>();
                return emptyWrapper;
            }
        } catch (Exception e) {
            System.debug('Error in getDueOrder: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving due order: ' + e.getMessage());
        }
    }
}