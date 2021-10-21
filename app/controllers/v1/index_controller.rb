module V1
  class IndexController < ApplicationController
    def yoyo
      render json: {yiyi: 1}
    end
  end
end