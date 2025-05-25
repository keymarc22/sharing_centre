module PriceableConcern
  extend ActiveSupport::Concern

  included do
    monetize :price_cents, as: :price, allow_nil: false, numericality: {
      greater_than: 0
    }
  end
end