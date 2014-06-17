class ChannelsController < ApplicationController
  def update
    channel = Channel.find(params[:id])
    channel.attributes = channel_params
    channel.save!

    respond_to do |format|
      format.js do
        render json: {success: true}
      end
    end
  end

  private

  def channel_params
    params.require(:channel).permit(:order)
  end
end