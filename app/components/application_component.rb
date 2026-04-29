class ApplicationComponent < ViewComponent::Base
  delegate :current_user, :tw, :lucide_icon, :turbo_frame_tag, to: :helpers

  def with_block?
    !content.nil?
  end
end