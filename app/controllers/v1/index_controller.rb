module V1
  class IndexController < ApiController
    def yoyo
      render json: {yiyi: 1}
    end
  end
end