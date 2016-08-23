class ShopJob < ActiveJob::Base
  around_perform :with_shopify_session

  private

  def with_shopify_session
    shop.with_shopify_session do
      yield
    end
  end

  def shop
    @shop ||= ::Shop.find_by!(shopify_domain: shopify_domain)
  end

  def shopify_domain
    params_hash = arguments.last

    if params_hash.is_a?(Hash) && params_hash[:shop_domain].present?
      params_hash[:shop_domain]
    else
      arguments.first
    end
  end
end
