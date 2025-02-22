module Internal
  class BadgesController < Internal::ApplicationController
    layout "internal"

    def index
      @badges = Badge.all
    end

    def award_badges
      raise ArgumentError, "Please choose a badge to award" if permitted_params[:badge].blank?

      usernames = permitted_params[:usernames].split(/\s*,\s*/)
      message = permitted_params[:message_markdown].presence || "Congrats!"
      BadgeAchievements::BadgeAwardWorker.perform_async(usernames, permitted_params[:badge], message)

      flash[:success] = "Badges are being rewarded. The task will finish shortly."
      redirect_to internal_badges_url
    rescue ArgumentError => e
      flash[:danger] = e.message
      redirect_to "/internal/badges"
    end

    private

    def permitted_params
      params.permit(:usernames, :badge, :message_markdown)
    end
  end
end
