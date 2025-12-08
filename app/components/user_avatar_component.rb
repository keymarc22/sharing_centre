# frozen_string_literal: true

class UserAvatarComponent < ApplicationComponent
  attr_reader :avatar

  def initialize(avatar:)
    @avatar = avatar
  end

  def render?
    false
  end
end
