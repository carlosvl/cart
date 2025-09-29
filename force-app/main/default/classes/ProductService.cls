public with sharing class ProductService {
	@AuraEnabled(cacheable=true)
	public static List<Product__c> getProducts(String name,	FilterWrapper filtersData) {
		String nameLike = '%' + name + '%';

		String query = 'SELECT Id, Name, Image_URL__c, Price__c, Brand__c, Size__c, Category__c FROM Product__c WHERE Name like :nameLike';

		System.debug('name ' + name);
		System.debug('filtersData ' + filtersData);
		if (filtersData != null) {

			if (filtersData.minPrice != null) {
				Decimal minPrice = filtersData.minPrice;
				query += ' AND Price__c >= :minPrice';
			}

			if (filtersData.maxPrice != null) {
				Decimal maxPrice = filtersData.maxPrice;
				query += ' AND Price__c <= :maxPrice';
			}

			if (String.isNotBlank(filtersData.category)) {
				String category = filtersData.category;
				query += ' AND Category__c = :category';
			}

			if (String.isNotBlank(filtersData.size)) {
				String size = filtersData.size;
				query += ' AND Size__c = :size';
			}
		}
		
		List<Product__c> products = (List<Product__c>) Database.query(query);
        
        // Get the latest file attachments for each product
        if (!products.isEmpty()) {
            Map<Id, Product__c> productMap = new Map<Id, Product__c>(products);
            
            // Query ContentDocumentLinks for all products
            List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :productMap.keySet()
            ];
            
            // Get the ContentDocument IDs
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id, Id> productToContentDocMap = new Map<Id, Id>();
            
            for (ContentDocumentLink link : contentLinks) {
                contentDocumentIds.add(link.ContentDocumentId);
                // Store the most recent content document for each product
                // (If there are multiple, the last one processed will be used)
                productToContentDocMap.put(link.LinkedEntityId, link.ContentDocumentId);
            }
            
            // Query ContentVersions to get the latest versions and their download URLs
            if (!contentDocumentIds.isEmpty()) {
                List<ContentVersion> contentVersions = [
                    SELECT Id, ContentDocumentId, VersionData, FileType, Title, FileExtension, ContentUrl
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :contentDocumentIds
                    AND IsLatest = true
                ];
                
                // Create a map of ContentDocumentId to ContentVersion
                Map<Id, ContentVersion> contentDocToVersionMap = new Map<Id, ContentVersion>();
                for (ContentVersion version : contentVersions) {
                    contentDocToVersionMap.put(version.ContentDocumentId, version);
                }
                
                // Update products with file URLs and add ContentVersionId for later retrieval
                for (Product__c product : products) {
                    Id contentDocId = productToContentDocMap.get(product.Id);
                    if (contentDocId != null && contentDocToVersionMap.containsKey(contentDocId)) {
                        ContentVersion version = contentDocToVersionMap.get(contentDocId);
                        // Store the ContentVersion ID in the Image_URL__c field temporarily
                        // This will be used by the getProductImage method to retrieve the actual image data
                        product.Image_URL__c = version.Id;
                    }
                }
            }
        }
        
		return products;
	}
	
    /**
     * Method to retrieve base64 encoded image data for a ContentVersion
     * This approach works in Experience Cloud because it doesn't rely on URL-based access
     */
    @AuraEnabled(cacheable=true)
    public static String getProductImage(String contentVersionId) {
        if (String.isBlank(contentVersionId)) {
            return null;
        }
        
        try {
            // Query the ContentVersion to get the VersionData (actual file content)
            ContentVersion cv = [
                SELECT VersionData, FileType
                FROM ContentVersion
                WHERE Id = :contentVersionId
                LIMIT 1
            ];
            
            if (cv != null) {
                // Convert the Blob to a base64 encoded string
                String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                
                // Return the base64 encoded string with the appropriate data URI prefix
                String fileType = cv.FileType.toLowerCase();
                if (fileType == 'jpg' || fileType == 'jpeg') {
                    return 'data:image/jpeg;base64,' + base64Data;
                } else if (fileType == 'png') {
                    return 'data:image/png;base64,' + base64Data;
                } else if (fileType == 'gif') {
                    return 'data:image/gif;base64,' + base64Data;
                } else {
                    // Default to jpeg if file type is unknown
                    return 'data:image/jpeg;base64,' + base64Data;
                }
            }
        } catch (Exception e) {
            System.debug('Error retrieving product image: ' + e.getMessage());
        }
        
        return null;
    }

	@AuraEnabled
	public static String createOrder(object data){
		List<ProductOrderWrapper> productData = (List<ProductOrderWrapper>) JSON.deserialize(JSON.serialize(data), List<ProductOrderWrapper>.class);

		Order__c ord = new Order__c();
		insert ord;

		List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();

		for(ProductOrderWrapper product : productData){
			Order_Line_Item__c oli = new Order_Line_Item__c();
			oli.Order__c = ord.Id;
			oli.Product__c = product.Id;
			oli.Price__c = product.price;
			oli.Quantity__c = product.quantity;
			oliList.add(oli);
		}

		insert oliList;
		
		return ord.Id;
	}

	public class FilterWrapper {
		@AuraEnabled
		public Decimal minPrice { get; set; }

		@AuraEnabled
		public Decimal maxPrice { get; set; }

		@AuraEnabled
		public String category { get; set; }

		@AuraEnabled
		public String size { get; set; }
	}

	public class ProductOrderWrapper {
		@AuraEnabled
		public String Id;

		@AuraEnabled
		public Decimal price;

		@AuraEnabled
		public Decimal totalPrice;

		@AuraEnabled
		public Integer quantity;

		@AuraEnabled
		public String Name;
	}
}