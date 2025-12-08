class ApplicationComponent < ViewComponent::Base
  delegate :current_user, :tw, :lucide_icon, to: :helpers

  def with_block?
    !content.nil?
  end
end