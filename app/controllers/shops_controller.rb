class ShopsController < ShopifyApp::AuthenticatedController
  def update
    shop.update_attributes!(shop_params)

    redirect_to root_path, notice: 'Details saved successfully!'
  end

  private

  def shop_params
    params.require(:shop).permit(:token, :cancel_order, :fulfill_order)
  end
end
