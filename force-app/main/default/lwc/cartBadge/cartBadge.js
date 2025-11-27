import { LightningElement, track, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import CART_CHANNEL from "@salesforce/messageChannel/productAddRemoveCartChannel__c";
import getDueOrder from "@salesforce/apex/OrderService.getDueOrder";
import convertOrderLineItemsToCartItems from "@salesforce/apex/ProductService.convertOrderLineItemsToCartItems";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CartBadge extends LightningElement {
  @track totalInCart = 0;
  @track cartData = [];
  @track dueOrderId;
  @track isLoading = false;
  subscription = null;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.subscribeMC();
    this.checkForDueOrders();
  }

  disconnectedCallback() {
    this.unsubscribeMC();
  }

  checkForDueOrders() {
    this.isLoading = true;

    getDueOrder()
      .then((result) => {
        if (result && result.order && result.order.Id) {
          this.dueOrderId = result.order.Id;

          // Dispatch event to parent component
          this.dispatchEvent(
            new CustomEvent("unpaidorderdetected", {
              detail: { hasUnpaidOrder: true },
              bubbles: true,
              composed: true
            })
          );

          this.showToast(
            "Order Found",
            `Found an unpaid order (${result.order.Name}). Items have been added to your cart.`,
            "info"
          );

          this.loadDueOrderItems(result.order.Id);
        }
      })
      .catch((error) => {
        console.error("Error checking for due orders:", error);
        this.showToast("Error", "Failed to check for existing orders", "error");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  loadDueOrderItems(orderId) {
    convertOrderLineItemsToCartItems({ orderId: orderId })
      .then((cartItems) => {
        if (cartItems && cartItems.length > 0) {
          this.cartData = cartItems;
          this.totalInCart = cartItems.length;
        }
      })
      .catch((error) => {
        console.error("Error loading order items:", error);
        this.showToast("Error", "Failed to load order items", "error");
      });
  }

  subscribeMC() {
    if (this.subscription) {
      return;
    }
    this.subscription = subscribe(
      this.messageContext,
      CART_CHANNEL,
      (message) => {
        console.log("message " + JSON.stringify(message));
        let cartData = message.cartData;
        let cartAction = message.action.cartAction;

        if (cartAction === "Add") {
          this.cartData.push(cartData);
          this.totalInCart++;
        } else if (cartAction === "Remove") {
          let productId = cartData.productId;
          let cartFilterData = this.cartData.filter(
            (ele) => ele.productId !== productId
          );
          this.cartData = cartFilterData;
          this.totalInCart--;
        }

        console.log(this.cartData);
      }
    );
  }

  unsubscribeMC() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleOpenCart() {
    let child = this.template.querySelector("c-cart-data");
    child.openModal(this.cartData);

    if (this.dueOrderId) {
      child.dueOrderId = this.dueOrderId;
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}