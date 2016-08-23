require 'net/http'
require 'uri'
require 'json'

class OrdersCreateJob < ShopJob
  include Rails.application.routes.url_helpers

  def perform(shop_domain:, webhook: nil)
    create_initial_risk(shop_domain, webhook)
    notify_service(shop_domain, webhook)
  end

  private

  def notify_service(shop_domain, webhook)
    addr = URI.parse("#{Rails.application.config.service_url}/notify/order")
    http = Net::HTTP.new(addr.host, addr.port)
    http.use_ssl = true

    http.post(
      addr.path,
      {
        shop_domain: shop_domain,
        order_id: webhook[:id],
        country_code: webhook.fetch(:billing_address, {})[:country_code],
        state_code: webhook.fetch(:billing_address, {})[:province_code],
        callback_url: callback_url,
      }.to_json,
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    )

    Rails.logger.info("[#{self.class.name}] Service response: 200")
  rescue => e
    Rails.logger.info("[#{self.class.name}] Service exception: #{e.class.name}")
  end

  def create_initial_risk(shop_domain, webhook)
    risk = ShopifyAPI::OrderRisk.new
    risk.prefix_options[:order_id] = webhook[:id]
    risk.cause_cancel = false
    risk.display = true
    risk.message = "ID validation required"
    risk.recommendation = :investigate
    risk.source = "external"
    risk.score = 0.5
    risk.save!
  end
end
