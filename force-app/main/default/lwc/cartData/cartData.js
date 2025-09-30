import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createOrder from '@salesforce/apex/ProductService.createOrder';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CartData extends NavigationMixin(LightningElement) {
    @track showModal = false;
    @track showLoading = false;
    @track products;
    @track totalPrice = 0;

  
    @api openModal(products) {
        console.log(products);
        this.totalPrice = 0;
        products.forEach(currentItem => {
            this.totalPrice = this.totalPrice + currentItem.totalPrice;
        });

        this.products = products;
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }

    get isDisable(){
        return !(this.products.length > 0) || this.showLoading;
    }

    handleOrder(){
        this.showLoading = true;
 
        createOrder({data:this.products})
        .then(result=>{
            let title = 'Order Created Successfully!!';
            this.showToast('Success!', title, 'success', 'dismissable');
            console.log('Order created with ID:', result);
            
            // Add a small delay before navigation to ensure toast is visible
            setTimeout(() => {
                this.navigateToOrderDetailsPage(result);
            }, 500);
        }).catch(err=>{
            console.error('Error creating order:', err);
            this.showToast('Error!!', err.body.message, 'error', 'dismissable');
        }).finally(() => {
            this.showLoading = false;
        })
    }

    navigateToOrderDetailsPage(recordId) {
        console.log('Attempting to navigate to order details with ID:', recordId);
        
        // Simply navigate to the record page - this is the most reliable approach
        // that works in both standard Lightning and Experience Cloud
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Order__c',
                actionName: 'view'
            }
        });
    }
    
    // Keep this method for backward compatibility or if we need to navigate to standard record page
    navigateToOrderPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Order__c',
                actionName: 'view'
            },
        });
    }
  
    showHideSpinner() {
        // Setting boolean variable show/hide spinner
        this.showLoading = !this.showLoading;
    }

    showToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    } 
}