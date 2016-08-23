class AppUninstallJob < ShopJob
  def perform(shop_domain:, webhook: nil)
    shop.destroy!
  end
end
