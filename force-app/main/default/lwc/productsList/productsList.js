import { LightningElement, api } from "lwc";

export default class ProductsList extends LightningElement {
	_products = [];
	
	@api 
	get products() {
		return this._products;
	}
	
	set products(value) {
		// Ensure we always have a valid array, even if undefined or null is passed
		this._products = Array.isArray(value) ? value : [];
	}
}