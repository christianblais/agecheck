class CallbackJob < ShopJob
  def perform(shop_domain:, order_id:, verified:)
    order = ShopifyAPI::Order.find(order_id)

    delete_existing_risk(order)

    if verified
      handle_successful_validation(order)
    else
      handle_failed_validation(order)
    end
  end

  private

  def delete_existing_risk(order)
    Rails.logger.info("[#{self.class.name}] Deleting any existing risk")
    risks = ShopifyAPI::OrderRisk.find(:all, params: { order_id: order.id })
    risks.each { |risk| risk.destroy }
  end

  def handle_successful_validation(order)
    Rails.logger.info("[#{self.class.name}] Create order tag")

    tags = order.tags.split(',')
    tags << 'ID Verified'
    order.tags = tags.join(',')
    order.save!

    return unless shop.fulfill_order

    Rails.logger.info("[#{self.class.name}] Fulfilling order")

    fulfillment = ShopifyAPI::Fulfillment.new
    fulfillment.prefix_options[:order_id] = order.id
    fulfillment.notify_customer = true
    fulfillment.save!
  end

  def handle_failed_validation(order)
    Rails.logger.info("[#{self.class.name}] Creating new risk")

    risk = ShopifyAPI::OrderRisk.new
    risk.prefix_options[:order_id] = order.id
    risk.cause_cancel = false
    risk.display = true
    risk.message = "ID validation failed"
    risk.recommendation = :investigate
    risk.source = "external"
    risk.score = 1
    risk.save!

    return unless shop.cancel_order

    Rails.logger.info("[#{self.class.name}] Cancelling order")

    order.cancel
  end
end
