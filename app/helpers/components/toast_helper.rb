module Components::ToastHelper
  def toast_type_for(flash_key)
    case flash_key.to_sym
    when :notice, :success
      :success
    when :alert, :error
      :error
    when :warning
      :warning
    else
      :info
    end
  end
end