# Age Verification Shopify App

This is a proof of concept, bootstraping app for an Age Verification service for Shopify. The app assumes the following flow;

### 1. New Order

This app receives order/create webhooks, and will react in the following way;

1. It creates an initial risk on the order, letting the merchant know the order requires some validation.
2. It sends a notification to the verification service, letting it know a new order was created.

### 2. Customer visits the Thank You page

Every time a customer visits the thank you page, Shopify will load our javascript asset. This is our chance to load any service-dependent javascript to show a potential form, something for the customer to validate her ID.

### 3. Customer completes validation

Whether it's through a form on the thank you page, or via email following the initial notification, the service is fully responsible to gather all required information. Ideally, this wouldn't be in this app.

### 4. Service warns the app of successful/failed validation

Once the validation has been done, the service calls the app again to let it know of its status.

On success;

1. Delete initial risk, which we don't need anymore.
2. [optional] Fulfill the order, which has now been properly validated.

On failure;

1. Delete initial risk, which we don't need anymore.
2. Create a final risk, asserting the failed validation.
3. [optional] Cancel the order, since we haven't been able to validate it.
