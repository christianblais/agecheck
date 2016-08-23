ShopifyApp.configure do |config|
  url_options = Rails.application.routes.default_url_options
  application_url = "#{url_options[:protocol]}://#{url_options[:host]}"

  config.api_key = ENV['SHOPIFY_CLIENT_API_KEY']
  config.secret = ENV['SHOPIFY_CLIENT_API_SECRET']
  config.scope = "write_orders, write_script_tags, write_fulfillments"
  config.embedded_app = true
  config.webhooks = [
    {
      topic: 'app/uninstalled',
      address: "#{application_url}/webhooks/app_uninstall",
      format: 'json'
    },
    {
      topic: 'orders/create',
      address: "#{application_url}/webhooks/orders_create",
      format: 'json'
    }
  ]
  config.scripttags = [
    {
      event: 'onload',
      src: "#{application_url}/javascript.js",
      display_scope: 'order_status'
    }
  ]
end
