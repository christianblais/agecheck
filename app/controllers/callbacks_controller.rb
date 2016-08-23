class CallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def javascript
    @shop = Shop.find_by!(shopify_domain: params.require(:shop))

    if @shop.token.present?
      @token = @shop.token
    else
      head :ok
    end
  end

  def callback
    CallbackJob.perform_later(
      shop_domain: params[:shop_domain],
      order_id: params[:order_id],
      verified: params[:verified],
    )

    head :ok
  end
end
