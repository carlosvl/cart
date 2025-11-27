import {LightningElement, api, wire, track} from "lwc";
// messageChannels
import { publish, MessageContext } from "lightning/messageService";
import CART_CHANNEL from "@salesforce/messageChannel/productAddRemoveCartChannel__c";
// Import the Apex method to get product images
import getProductImage from "@salesforce/apex/ProductService.getProductImage";

export default class ProductTile extends LightningElement {
	@api product;
	@track imageData;
	@track imageLoading = true;
	@track imageError = false;

	@wire(MessageContext)
	messageContext;
	
	connectedCallback() {
		// If we have a product with an Image_URL__c (which now contains ContentVersionId)
		// fetch the actual image data
		if (this.product && this.product.Image_URL__c) {
			this.loadProductImage();
		}
	}
	
	loadProductImage() {
		this.imageLoading = true;
		this.imageError = false;
		
		getProductImage({ contentVersionId: this.product.Image_URL__c })
			.then(result => {
				if (result) {
					this.imageData = result;
				} else {
					this.imageError = true;
				}
			})
			.catch(error => {
				console.error('Error loading product image:', error);
				this.imageError = true;
			})
			.finally(() => {
				this.imageLoading = false;
			});
	}

	publishChange(cartData, cartAction) {
		const message = {
			cartData: cartData,
			action:{
				cartAction : cartAction
			}
		};
		publish(this.messageContext, CART_CHANNEL, message);
	}

	@api
	get addedToCart() {
		return this.isAddedToCart;
	}
	set addedToCart(value) {
		this.isAddedToCart = value;
	}

	@api
	get defaultQuantity() {
		return this.quantity;
	}

	set defaultQuantity(value) {
		this.quantity = value;
	}

	quantity = 1;
	isAddedToCart;

	handleAddToCart() {
		this.isAddedToCart = true;
		let cartData = {
			productId: this.product.Id,
			Id : this.product.Id,
			quantity: this.quantity,
			Name : this.product.Name,
			price : this.product.Price__c,
			totalPrice : (this.quantity * this.product.Price__c),
		}
		this.publishChange(cartData, 'Add');
	}

	handleRemoveFromCart() {
		this.isAddedToCart = false;
		let cartData = {
			productId: this.product.Id,
		}
		this.publishChange(cartData, 'Remove');
		
	}

	handleChange(event) {
		this.quantity = event.target.value;
	}

	get backgroundStyle() {
		if (this.imageData) {
			// Use the base64 encoded image data directly
			return `background-image:url(${this.imageData})`;
		} else if (this.imageLoading) {
			// Show a loading state
			return 'background-color: #f3f3f3;';
		} else if (this.imageError || !this.product.Image_URL__c) {
			// Show a default placeholder for error or missing image
			return 'background-color: #f3f3f3;';
		}
		// Default fallback
		return 'background-color: #f3f3f3;';
	}

	get totalPrice() {
		return this.quantity * this.product.Price__c;
	}
}